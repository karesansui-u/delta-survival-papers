"""Generate all figures for the Context Rot paper.

Usage:
    cd papers/context_rot
    python generate_figures.py
"""

import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.rcParams['font.size'] = 11
matplotlib.rcParams['figure.dpi'] = 300


def fig1_exp35():
    """Figure 1: Exp35 — δ=0 vs δ>0 across 6 models."""
    models = [
        'GPT-4o-mini\n(96K)',
        'Gemini 2.5\nFlash (64K)',
        'Gemini 3.1\nFL (1M)',
        'Sonnet 4\n(8K)',
        'Sonnet 4.6\n(128K)',
        'Llama 3.1\n8b (8K)',
    ]
    d0 = [100, 100, 88.6, 100, 100, 34.0]
    d1 = [10.4, 0, 40.8, 74.0, 100, 2.7]

    fig, ax = plt.subplots(figsize=(10, 5))
    x = np.arange(len(models))
    w = 0.35

    bars1 = ax.bar(x - w/2, d0, w, label='δ=0 (no contradictions)', color='#4CAF50', alpha=0.85)
    bars2 = ax.bar(x + w/2, d1, w, label='δ>0 (with contradictions)', color='#F44336', alpha=0.85)

    ax.set_ylabel('Accuracy (%)')
    ax.set_title('Effect of Contradiction Accumulation on LLM Accuracy')
    ax.set_xticks(x)
    ax.set_xticklabels(models, fontsize=9)
    ax.set_ylim(0, 115)
    ax.legend(loc='upper right')
    ax.axhline(y=50, color='gray', linestyle='--', alpha=0.3)

    # Add drop annotations
    for i in range(len(models)):
        drop = d1[i] - d0[i]
        if drop != 0:
            # Place label above bar, or above zero line if bar is very short
            label_y = max(d1[i] + 3, 8)
            ax.annotate(f'{drop:+.1f}pp',
                       xy=(x[i] + w/2, label_y),
                       ha='center', fontsize=9, color='#D32F2F', fontweight='bold')

    plt.tight_layout()
    plt.savefig('fig1_exp35.pdf')
    plt.savefig('fig1_exp35.png')
    plt.close()
    print('  fig1_exp35 done')


def fig2_architecture():
    """Figure 2: Architecture diagram — created manually in TikZ or draw.io.
    Placeholder note only."""
    print('  fig2_architecture: use TikZ in main.tex (already sketched)')


def fig3_forest_plot():
    """Figure 3: Forest plot of 11-pair ON-OFF differences."""
    data = [
        ('mistral-nemo T2', 42.2),
        ('llama3.1 T1', 20.0),
        ('gemma3:12b T1', 17.8),
        ('gemma3:12b (g) T1', 15.6),
        ('gemma3:27b T1', 15.0),
        ('deepseek T1', 8.9),
        ('deepseek T2', 8.9),
        ('llama3.1 T2', 8.9),
        ('mistral-nemo T1', 8.9),
        ('llama3.1 T3', 0.0),
        ('qwen2.5 T1', -2.2),
    ]

    labels = [d[0] for d in data]
    diffs = [d[1] for d in data]
    colors = ['#4CAF50' if d > 0 else '#F44336' if d < 0 else '#9E9E9E' for d in diffs]

    fig, ax = plt.subplots(figsize=(8, 6))
    y_pos = np.arange(len(labels))

    ax.barh(y_pos, diffs, color=colors, alpha=0.85, height=0.6)
    ax.set_yticks(y_pos)
    ax.set_yticklabels(labels, fontsize=9)
    ax.set_xlabel('ON − OFF (percentage points)')
    ax.set_title('Metabolism Effect by Model (180 turns, corrected)')
    ax.axvline(x=0, color='black', linewidth=0.8)
    ax.invert_yaxis()

    # Add value labels
    for i, v in enumerate(diffs):
        offset = 1 if v >= 0 else -1
        ha = 'left' if v >= 0 else 'right'
        ax.text(v + offset, i, f'{v:+.1f}', va='center', ha=ha, fontsize=8)

    # Add sign test result
    ax.text(0.98, 0.02, 'Sign test: 9/10, p = 0.0107\nModel-level: 6/7, p = 0.0625',
            transform=ax.transAxes, ha='right', va='bottom',
            fontsize=8, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    plt.savefig('fig3_forest_plot.pdf')
    plt.savefig('fig3_forest_plot.png')
    plt.close()
    print('  fig3_forest_plot done')


def fig4_ablation():
    """Figure 4: Ablation 2×2 bar chart."""
    conditions = ['ON\n(new code)', 'ON\n(old code)', 'OFF\n(new code)', 'OFF\n(old code)']
    values = [57.8, 8.9, 15.6, 22.2]
    colors = ['#4CAF50', '#A5D6A7', '#EF9A9A', '#F44336']

    fig, ax = plt.subplots(figsize=(7, 5))
    bars = ax.bar(conditions, values, color=colors, alpha=0.85, width=0.6)

    ax.set_ylabel('Accuracy (%)')
    ax.set_title('Controlled Ablation: Temporal Integration Effect\n(mistral-nemo:12b, 180 turns)')
    ax.set_ylim(0, 70)

    for bar, val in zip(bars, values):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
                f'{val}%', ha='center', fontweight='bold', fontsize=10)

    # Add annotation
    ax.annotate('', xy=(0, 57.8), xytext=(1, 8.9),
               arrowprops=dict(arrowstyle='<->', color='#1565C0', lw=2))
    ax.text(0.5, 35, '+48.9pp\n(code change)', ha='center', fontsize=10,
            color='#1565C0', fontweight='bold')

    ax.annotate('', xy=(2, 15.6), xytext=(3, 22.2),
               arrowprops=dict(arrowstyle='<->', color='gray', lw=1.5))
    ax.text(2.5, 20, '≈ same', ha='center', fontsize=9, color='gray')

    plt.tight_layout()
    plt.savefig('fig4_ablation.pdf')
    plt.savefig('fig4_ablation.png')
    plt.close()
    print('  fig4_ablation done')


def fig5_three_condition():
    """Figure 5: Three-condition bar chart with error bars (n=3)."""
    conditions = ['Metabolism\nON', 'No contradiction\n(δ=0)', 'Metabolism\nOFF']
    means = [73.3, 56.7, 21.1]
    sds = [6.7, 5.8, 5.1]
    colors = ['#4CAF50', '#FFC107', '#F44336']

    fig, ax = plt.subplots(figsize=(7, 5.5))
    x = np.arange(len(conditions))
    bars = ax.bar(x, means, yerr=sds, capsize=8, color=colors, alpha=0.85, width=0.5,
                  error_kw={'linewidth': 2})

    ax.set_ylabel('Accuracy (%) — fact + rule, 30 questions')
    ax.set_title('Three-Condition Comparison\n(gemma3:27b, 180 turns, n=3)')
    ax.set_xticks(x)
    ax.set_xticklabels(conditions, fontsize=10)
    ax.set_ylim(0, 95)

    # Add individual trial points
    trial_data = {
        0: [73.3, 66.7, 80.0],  # ON
        1: [60.0, 50.0, 60.0],  # NC
        2: [16.7, 26.7, 20.0],  # OFF
    }
    for i, trials in trial_data.items():
        ax.scatter([i]*3, trials, color='black', s=30, zorder=5, alpha=0.6)

    # Add mean labels
    for i, (m, s) in enumerate(zip(means, sds)):
        ax.text(i, m + s + 2, f'{m:.1f}%', ha='center', fontweight='bold', fontsize=11)

    # Add significance brackets
    def add_bracket(ax, x1, x2, y, text):
        ax.annotate('', xy=(x1, y), xytext=(x2, y),
                    arrowprops=dict(arrowstyle='-', lw=1.5))
        ax.plot([x1, x1], [y-1, y], 'k-', lw=1.5)
        ax.plot([x2, x2], [y-1, y], 'k-', lw=1.5)
        ax.text((x1+x2)/2, y+1, text, ha='center', fontsize=8)

    add_bracket(ax, 0, 2, 87, 'p = 0.027 (KW)')
    add_bracket(ax, 0, 1, 82, 'p = 0.05 (MW)')

    plt.tight_layout()
    plt.savefig('fig5_three_condition.pdf')
    plt.savefig('fig5_three_condition.png')
    plt.close()
    print('  fig5_three_condition done')


if __name__ == '__main__':
    print('Generating figures...')
    fig1_exp35()
    fig2_architecture()
    fig3_forest_plot()
    fig4_ablation()
    fig5_three_condition()
    print('All figures generated.')
