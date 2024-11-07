%-------------------------------------------------------------------------
% README
% 
% Format:
% - Parent Directory containing sub-xx folders for each subject
% - Within each sub-xx folder, there should be two folders: anat & func
% - The preprocessed file should be contained in the func folder for each
% subject
%
% For Ashley <3
% sub- folders location: /Users/nprluser/Documents/AP/AP_Nav_Subjects
%-------------------------------------------------------------------------
%----------------------------- Instructions -----------------------------%

disp("Welcome to Ashley Pelton's Functional Connectivity Script!\nThis script takes two specified ROIs and conducts a functional connectivity (FC) analysis between them.")
disp("The average activation of the subcortical ROI is ")



%------------------------ Initializing Variables ------------------------%

% Asking for user input for filepaths
sub_location = input('What is the path to your Parent Directory containing sub- Folders:\n', 's');

% Asking for user input for ROI masks
ppc_mask = input('What is the path to your Cortical ROI Mask:\n', 's');
rsc_mask = input('What is the path to your Subcortical ROI Mask:\n', 's');

% Determining the prefix/suffix to assist in locating the preprocessed file
tag_location = input("Does your final preprocessed filename include a prefix or a suffix? Input 'P' for a prefix convention and a 'S' for a suffix convention.\n--->Example: For the filename 'smooth_norm_stc_realign_sub-00_BOLD.nii', 'smooth_' is considered the most recent prefix.\n", 's');

if tag_location == 'P'
    tag = input("What is the prefix of your most preprocessed file?\n--->Example: For the filename 'smooth_norm_stc_realign_sub-00_BOLD.nii', you may input 'smooth_'.\n", 's');
end

if tag_location == 'S'
    tag = input("What is the suffix of your most preprocessed file, INCLUDING the file format?\n--->Example: For the filename 'sub-00_BOLD_realign_stc_norm_smooth.nii', you may input '_smooth.nii'.\n", 's');
end

% Creating list of items in sub- directory
sub_items = dir(sub_location);

% Creating list of names of folders in the sub- directory
sub_folders = {sub_items([sub_items.isdir]).name};

% Initializing array of subjects
subjects = {};

% Iterating through each folder name. Adding sub- folders to array of subjects
for i = 1:length(sub_folders)
    folder = sub_folders{i};
    if startsWith(folder, 'sub-')
        subjects{end+1} = folder;
    end
end

% Updating subject array type
subjects = string(subjects);

%---------------------------- 1st Analysis -----------------------------%

% Looping through each subject to be analyzed
for subject = subjects
    fprintf('Performing 1st Analysis for %s:\n', subject);

    subject_func = sprintf('%s/%s/func', sub_location, subject);

    % Locate files with the specified prefix
    if tag_location == 'P'
        tag_files = dir(fullfile(subject_func, [tag, '*']));
        
        % Check if there are any matching files
        if ~isempty(tag_files)  
            preproc_file = {tag_files.name};
        else
            warning('No files found for subject %s with tag %s.', subject, tag);
        end
    end

    % Locate files with the specified suffix
    if tag_location == 'S'
        tag_files = dir(fullfile(subject_func, ['*' tag]));

        % Check if there are any matching files
        if ~isempty(tag_files)  
            preproc_file = {tag_files.name};
        else
            warning('No files found for subject %s with suffix %s.', subject, tag);
        end
    end


end



