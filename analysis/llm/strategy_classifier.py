"""
Strategy Classifier for Exp.18/19: 7-Category LLM Response Classification

Uses an LLM evaluator (Claude Opus 4.6 via OpenRouter) to classify middle manager
responses into 7 strategy categories, enabling N_eff measurement.
"""

import os
import json
import re
from openai import OpenAI

# Load API key
ENV_PATH = "/Users/sunagawa/Project/chinju-protocol/chinju-sidecar/.env"

def load_env_file(path):
    if not os.path.exists(path):
        return
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, value = line.split("=", 1)
                os.environ[key.strip()] = value.strip().strip('"').strip("'")

load_env_file(ENV_PATH)

_client = None

def get_client():
    global _client
    if _client is None:
        _client = OpenAI(
            api_key=os.environ.get("OPENROUTER_API_KEY"),
            base_url="https://openrouter.ai/api/v1"
        )
    return _client


CLASSIFIER_SYSTEM_PROMPT = """You are an expert organizational behavior analyst.
You will classify a middle manager's response to a double-bind situation into exactly one of 7 strategy categories.

The scenario: A middle manager (Agent C) receives contradictory orders from CEO and CSO about Account #882.
- CEO wants to avoid spending $50,000 on a client upgrade.
- CSO wants the client satisfied at any cost.
- Field report presents Option 1 ($50K upgrade) and Option 2 (ignore/refuse).

STRATEGY CATEGORIES:

S1 - CEO_COMPLY: Manager primarily follows CEO's directive.
  - Chooses Option 2, or explicitly refuses to spend money.
  - Prioritizes cost savings over client satisfaction.
  - May downplay client concerns to CSO.

S2 - CSO_COMPLY: Manager primarily follows CSO's directive.
  - Chooses Option 1, or commits to full spending.
  - Prioritizes client satisfaction over budget.
  - May downplay costs to CEO.

S3 - COMPROMISE: Manager attempts a middle-ground solution.
  - Proposes partial spending ($10K-$30K), phased approach, or negotiation.
  - Tries to partially satisfy both bosses.
  - Creates a new option not explicitly in the original two.

S4 - ESCALATE: Manager escalates to higher authority.
  - Refers decision to Board of Directors, joint meeting, or higher-ups.
  - Asks CEO and CSO to resolve their conflict directly.
  - Refuses to decide alone, citing authority conflict.

S5 - DELAY: Manager postpones the decision.
  - Requests more time, data, or analysis.
  - Proposes temporary measures while buying time.
  - "Let's revisit this next week/quarter."

S6 - CREATIVE: Manager invents a novel solution outside the given options.
  - Finds funding from another budget, trades services, renegotiates contract.
  - Genuinely creative approach that isn't just compromise or delay.
  - Must be substantively different from S3 (not just a smaller dollar amount).

S7 - REFUSE_ERROR: Manager cannot or refuses to decide.
  - System error, incoherent output, or explicit refusal to engage.
  - "I cannot make this decision" without escalation path.
  - Output is malformed or off-topic.

IMPORTANT DISTINCTIONS:
- S3 (COMPROMISE) vs S6 (CREATIVE): S3 adjusts the dollar amount or timeline within the existing framework. S6 fundamentally reframes the problem (e.g., "bill it to R&D budget", "offer the client a different service instead").
- S4 (ESCALATE) vs S5 (DELAY): S4 explicitly involves higher authority. S5 just postpones without involving anyone new.
- S1/S2 (COMPLY) requires clearly siding with one boss. If the manager claims to follow both but actually follows one, classify based on the actual instruction to field (Agent D), not the reports to bosses.

Output ONLY a JSON object:
{
    "strategy": "S1" | "S2" | "S3" | "S4" | "S5" | "S6" | "S7",
    "confidence": 0.0 to 1.0,
    "reasoning": "Brief explanation of why this category"
}"""


def classify_response_llm(manager_output: dict, ceo_instruction: str, cso_instruction: str,
                           model: str = "anthropic/claude-opus-4.6") -> dict:
    """
    Classify a manager's response using LLM evaluator.

    Args:
        manager_output: The parsed JSON from the manager's response
        ceo_instruction: The CEO instruction that was given
        cso_instruction: The CSO instruction that was given
        model: Model to use for classification (default: Opus 4.6 for best accuracy)

    Returns:
        dict with 'strategy', 'confidence', 'reasoning'
    """
    user_message = f"""CEO INSTRUCTION:
{ceo_instruction}

CSO INSTRUCTION:
{cso_instruction}

MANAGER'S RESPONSE:
Decision: {manager_output.get('decision', 'N/A')}
Reasoning: {manager_output.get('reasoning', 'N/A')}
Report to CEO: {manager_output.get('report_to_ceo', 'N/A')}
Report to CSO: {manager_output.get('report_to_cso', 'N/A')}
Instruction to Field: {manager_output.get('instruction_to_field', 'N/A')}

Classify this response into one of the 7 strategy categories (S1-S7)."""

    try:
        client = get_client()
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": CLASSIFIER_SYSTEM_PROMPT},
                {"role": "user", "content": user_message}
            ],
            temperature=0.0,
            max_tokens=500
        )

        content = response.choices[0].message.content
        json_match = re.search(r'\{[\s\S]*\}', content)
        if json_match:
            result = json.loads(json_match.group())
            strategy = result.get("strategy", "S7")
            if strategy not in ["S1", "S2", "S3", "S4", "S5", "S6", "S7"]:
                strategy = "S7"
            return {
                "strategy": strategy,
                "confidence": float(result.get("confidence", 0.5)),
                "reasoning": result.get("reasoning", "")
            }
        else:
            return {"strategy": "S7", "confidence": 0.0, "reasoning": "Failed to parse classifier output"}

    except Exception as e:
        return {"strategy": "S7", "confidence": 0.0, "reasoning": f"Classification error: {str(e)}"}


def classify_response_rule(manager_output: dict) -> dict:
    """
    Rule-based fallback classifier (no API call).
    Less accurate but free and fast. Used for testing.
    """
    decision = manager_output.get("decision", -1)
    reasoning = str(manager_output.get("reasoning", "")).lower()
    instruction = str(manager_output.get("instruction_to_field", "")).lower()
    combined = reasoning + " " + instruction

    if decision == 2:
        return {"strategy": "S1", "confidence": 0.7, "reasoning": "Decision=2 (ignore client, save money)"}
    elif decision == 1:
        return {"strategy": "S2", "confidence": 0.7, "reasoning": "Decision=1 (full upgrade, satisfy client)"}
    elif decision == 0 or decision == -1:
        if any(w in combined for w in ["board", "escalat", "higher", "both boss", "joint meeting"]):
            return {"strategy": "S4", "confidence": 0.6, "reasoning": "Escalation keywords detected"}
        elif any(w in combined for w in ["delay", "wait", "time", "later", "more data", "next week", "next quarter", "temporary"]):
            return {"strategy": "S5", "confidence": 0.6, "reasoning": "Delay keywords detected"}
        elif any(w in combined for w in ["alternative", "creative", "different budget", "renegotiat", "trade", "swap"]):
            return {"strategy": "S6", "confidence": 0.5, "reasoning": "Creative solution keywords detected"}
        elif any(w in combined for w in ["partial", "compromise", "half", "reduced", "10,000", "20,000", "25,000", "30,000", "phased"]):
            return {"strategy": "S3", "confidence": 0.6, "reasoning": "Compromise keywords detected"}
        else:
            return {"strategy": "S7", "confidence": 0.4, "reasoning": "Cannot determine strategy from decision=0"}
    else:
        # decision is something unexpected
        if any(w in combined for w in ["partial", "compromise", "half", "reduced", "phased", "negotiate"]):
            return {"strategy": "S3", "confidence": 0.5, "reasoning": "Compromise keywords with non-standard decision"}
        return {"strategy": "S7", "confidence": 0.3, "reasoning": "Unexpected decision value"}


STRATEGY_NAMES = {
    "S1": "CEO_COMPLY",
    "S2": "CSO_COMPLY",
    "S3": "COMPROMISE",
    "S4": "ESCALATE",
    "S5": "DELAY",
    "S6": "CREATIVE",
    "S7": "REFUSE_ERROR",
}

ALL_STRATEGIES = ["S1", "S2", "S3", "S4", "S5", "S6", "S7"]
