function export_oxford_part1_training_tables(root_dir, output_root, mode, max_records, confirm_heldout_primary)
% Export Oxford Path Dependent Part 1 MATLAB tables for frozen runner modes.
%
% This converter is intentionally no-peek:
% - train_smoke mode exports training cell IDs only;
% - heldout_primary mode exports held-out cell IDs only and must be called
%   only by the frozen one-time primary runner;
% - no endpoints, features, model metrics, predictions, or support flags are
%   computed here.

if nargin < 1 || isempty(root_dir)
    root_dir = fullfile('analysis', 'g4_battery_m_profile', 'data', ...
        'oxford_path_dependent', 'part1');
end
if nargin < 2 || isempty(output_root)
    output_root = fullfile('analysis', 'g4_battery_m_profile', 'data', ...
        'oxford_path_dependent_converted', 'train_smoke');
end
if nargin < 3 || isempty(mode)
    mode = 'train_smoke';
end
if nargin < 4 || isempty(max_records)
    max_records = Inf;
end
if nargin < 5
    confirm_heldout_primary = '';
end

allowed_modes = {'train_smoke', 'heldout_primary'};
if ~ismember(mode, allowed_modes)
    error('Unsupported mode: %s', mode);
end
if strcmp(mode, 'heldout_primary')
    env_confirm = getenv('OXFORD_CONFIRM_HELDOUT_PRIMARY');
    if ~(strcmp(confirm_heldout_primary, 'CONFIRM_HELDOUT_PRIMARY') || strcmp(env_confirm, '1'))
        error(['heldout_primary conversion requires explicit confirmation. ', ...
            'Use the guarded one-time primary runner or pass CONFIRM_HELDOUT_PRIMARY.']);
    end
end
if ~(isnumeric(max_records) && isscalar(max_records) && max_records > 0)
    error('max_records must be a positive scalar or Inf.');
end
if isinf(max_records)
    max_records_manifest = 'Inf';
else
    max_records_manifest = max_records;
end

train_cell_ids = [4, 8, 10, 14, 15, 18, 19, 20];
heldout_cell_ids = [3, 9, 11, 12];
group_archives = {'Group_1.zip', 'Group_2.zip', 'Group_3.zip', 'Group_4.zip'};

if any(ismember(train_cell_ids, heldout_cell_ids))
    error('Train/test cell ID sets overlap.');
end

if isfolder(output_root) && dir_has_entries(output_root)
    error('Refusing to write into non-empty output root: %s', output_root);
end
ensure_dir(output_root);
tables_root = fullfile(output_root, 'tables');
ensure_dir(tables_root);

if strcmp(mode, 'train_smoke')
    manifest_status = 'train_smoke_conversion_manifest';
    selected_cell_ids = train_cell_ids;
    forbidden_cell_ids = heldout_cell_ids;
    heldout_payload_exported = false;
    record_label = 'training-table';
elseif strcmp(mode, 'heldout_primary')
    manifest_status = 'heldout_primary_conversion_manifest';
    selected_cell_ids = heldout_cell_ids;
    forbidden_cell_ids = train_cell_ids;
    heldout_payload_exported = true;
    record_label = 'heldout-table';
else
    error('Unreachable mode: %s', mode);
end

manifest = struct( ...
    'status', manifest_status, ...
    'mode', mode, ...
    'root_dir', root_dir, ...
    'output_root', output_root, ...
    'train_cell_ids', train_cell_ids, ...
    'heldout_cell_ids', heldout_cell_ids, ...
    'max_records', max_records_manifest, ...
    'truncated_by_max_records', false, ...
    'heldout_payload_exported', heldout_payload_exported, ...
    'metrics_computed', false, ...
    'support_flags_emitted', false ...
);

record_index = 0;
records = struct([]);
temp_root = tempname;
cleanup_obj = onCleanup(@() cleanup_dir(temp_root));
ensure_dir(temp_root);
stop_requested = false;

for archive_idx = 1:numel(group_archives)
    if stop_requested
        break;
    end
    archive_name = group_archives{archive_idx};
    archive_path = fullfile(root_dir, archive_name);
    if ~isfile(archive_path)
        error('Missing archive: %s', archive_path);
    end

    zip_file = java.util.zip.ZipFile(java.io.File(archive_path));
    zip_cleanup = onCleanup(@() zip_file.close());
    entries = zip_file.entries();

    while entries.hasMoreElements()
        entry = entries.nextElement();
        entry_name = char(entry.getName());
        parsed = parse_entry_name(entry_name);
        if ~parsed.matched
            continue;
        end

        if ismember(parsed.cell_id, forbidden_cell_ids)
            continue;
        end
        if ~ismember(parsed.cell_id, selected_cell_ids)
            error('Unexpected non-selected cell ID %d in %s', ...
                parsed.cell_id, entry_name);
        end

        try
            extracted_path = extract_zip_entry(zip_file, entry, temp_root, archive_path);
            loaded = load(extracted_path);
            [table_name, table_value] = select_table_variable(loaded, parsed, entry_name);

            output_name = sprintf('group%d_cell%d_index%d.csv', ...
                parsed.group_id, parsed.cell_id, parsed.diagnostic_index);
            output_path = fullfile(tables_root, output_name);
            relative_output_path = fullfile('tables', output_name);
            writetable(table_value, output_path);
        catch ME
            error('Failed to convert %s from %s: %s', entry_name, archive_name, ME.message);
        end

        record_index = record_index + 1;
        records(record_index).archive = archive_name; %#ok<AGROW>
        records(record_index).entry_name = entry_name; %#ok<AGROW>
        records(record_index).group_id = parsed.group_id; %#ok<AGROW>
        records(record_index).cell_id = parsed.cell_id; %#ok<AGROW>
        records(record_index).diagnostic_index = parsed.diagnostic_index; %#ok<AGROW>
        records(record_index).table_variable_name = table_name; %#ok<AGROW>
        records(record_index).column_names = table_value.Properties.VariableNames; %#ok<AGROW>
        records(record_index).row_count = height(table_value); %#ok<AGROW>
        records(record_index).column_count = width(table_value); %#ok<AGROW>
        records(record_index).output_csv = relative_output_path; %#ok<AGROW>
        records(record_index).output_sha256 = file_sha256(output_path); %#ok<AGROW>
        if record_index == 1 || mod(record_index, 10) == 0
            fprintf('Converted %d %s records; latest: %s\n', ...
                record_index, record_label, entry_name);
        end

        if record_index >= max_records
            stop_requested = true;
            manifest.truncated_by_max_records = true;
            break;
        end
    end

    clear zip_cleanup;
end

manifest.record_count = record_index;
manifest.records = records;
manifest_path = fullfile(output_root, 'conversion_manifest.json');
write_json(manifest_path, manifest);
fprintf('Wrote %d %s records to %s\n', record_index, record_label, output_root);
if strcmp(mode, 'heldout_primary')
    fprintf('Held-out primary conversion completed for frozen one-time runner.\n');
end
end

function parsed = parse_entry_name(entry_name)
pattern_with_index = '^Group\s+(\d+)/TPG(\d+)\.(\d+)\s*-\s*Cell\s*(\d+)\.mat$';
tokens = regexp(entry_name, pattern_with_index, 'tokens', 'once', 'ignorecase');
if ~isempty(tokens)
    group_id = str2double(tokens{1});
    tpg_group_id = str2double(tokens{2});
    diagnostic_index = str2double(tokens{3});
    cell_id = str2double(tokens{4});
else
    pattern_without_index = '^Group\s+(\d+)/TPG(\d+)\s*-\s*Cell\s*(\d+)\.mat$';
    tokens = regexp(entry_name, pattern_without_index, 'tokens', 'once', 'ignorecase');
    if isempty(tokens)
        parsed = struct('matched', false);
        return;
    end
    group_id = str2double(tokens{1});
    tpg_group_id = str2double(tokens{2});
    diagnostic_index = 0;
    cell_id = str2double(tokens{3});
end
if group_id ~= tpg_group_id
    error('Group and TPG group mismatch in entry: %s', entry_name);
end
parsed = struct( ...
    'matched', true, ...
    'group_id', group_id, ...
    'diagnostic_index', diagnostic_index, ...
    'cell_id', cell_id ...
);
end

function [table_name, table_value] = select_table_variable(loaded, parsed, entry_name)
if parsed.diagnostic_index == 0
    expected_table_name = sprintf('TPG%d_Cell%d', parsed.group_id, parsed.cell_id);
else
    expected_table_name = sprintf('TPG%d_%d_Cell%d', ...
        parsed.group_id, parsed.diagnostic_index, parsed.cell_id);
end

if isfield(loaded, expected_table_name)
    table_value = loaded.(expected_table_name);
    if ~istable(table_value)
        error('Expected variable %s in %s to be a table.', expected_table_name, entry_name);
    end
    table_name = expected_table_name;
    return;
end

variable_names = fieldnames(loaded);
table_names = {};
for variable_idx = 1:numel(variable_names)
    candidate_name = variable_names{variable_idx};
    if istable(loaded.(candidate_name))
        table_names{end + 1} = candidate_name; %#ok<AGROW>
    end
end

if numel(table_names) == 1
    table_name = table_names{1};
    table_value = loaded.(table_name);
    return;
end

error('Could not select a unique table variable in %s. Expected %s, table candidates: %s.', ...
    entry_name, expected_table_name, strjoin(table_names, ', '));
end

function output_path = extract_zip_entry(zip_file, entry, temp_root, archive_path)
entry_name = char(entry.getName());
[~, base_name, ext] = fileparts(entry_name);
output_path = fullfile(temp_root, [base_name ext]);

% Use the system unzip implementation for the selected entry only. MATLAB's
% Java byte-array bridge can corrupt these MCOS table MAT payloads on macOS.
command = sprintf('/usr/bin/unzip -p %s %s > %s', ...
    shell_quote(archive_path), shell_quote(entry_name), shell_quote(output_path));
[status, command_output] = system(command);
if status ~= 0
    error('Failed to extract %s from %s: %s', entry_name, archive_path, command_output);
end

expected_size = entry.getSize();
file_info = dir(output_path);
total_written = file_info.bytes;
if expected_size >= 0 && total_written ~= expected_size
    error('Extracted byte count mismatch for %s: got %d, expected %d.', ...
        entry_name, total_written, expected_size);
end
end

function quoted = shell_quote(value)
value = char(value);
quoted = ['''' strrep(value, '''', '''"''"''') ''''];
end

function digest = file_sha256(path)
command = sprintf('/usr/bin/shasum -a 256 %s', shell_quote(path));
[status, command_output] = system(command);
if status ~= 0
    error('Failed to compute SHA256 for %s: %s', path, command_output);
end
parts = regexp(strtrim(command_output), '\s+', 'split');
digest = lower(parts{1});
end

function write_json(path, value)
try
    encoded = jsonencode(value, 'PrettyPrint', true);
catch
    encoded = jsonencode(value);
end
fid = fopen(path, 'w');
if fid < 0
    error('Could not open manifest for writing: %s', path);
end
cleanup_obj = onCleanup(@() fclose(fid));
fprintf(fid, '%s\n', encoded);
clear cleanup_obj;
end

function ensure_dir(path)
if ~isfolder(path)
    mkdir(path);
end
end

function has_entries = dir_has_entries(path)
listing = dir(path);
names = {listing.name};
has_entries = any(~ismember(names, {'.', '..'}));
end

function cleanup_dir(path)
if isfolder(path)
    rmdir(path, 's');
end
end
