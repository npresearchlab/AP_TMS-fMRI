%-------------------------------------------------------------------------
% README
% 
% Format:
% - Parent Directory containing sub-xx folders for each participant
% - Within each sub-xx folder, there should be two folders: anat & func
% - The anat & func folders can have any files within it, but it needs
% either .dcm files or a .nii file for the anat & func files
% - If .dcm have been converted to .nii:
%      func .nii file is titled - sub-xx_bold.nii
%      anat .nii file is titled - sub-xx_t1.nii
%
%
% For Ashley <3
% sub- folders location: /Users/nprluser/Documents/AP/AP_Nav_Subjects
% spm12 folder location: /Users/nprluser/Documents/AP/AP_TMS-fMRI
% dcm2niix location:/Library/Frameworks/PythonVersions/3.12/bin/dcm2niix
% Slice Number = 72
% TR = 1.5 s
% Slice Order = Interleaved, Bottom-to-Top
% FWHM: 4
%-------------------------------------------------------------------------
%-------------------------------- Notes ---------------------------------%
%
%
%------------------------ Initializing Variables ------------------------%

% Asking for user input for filepaths
sub_location = input('Path to Parent Directory containing sub- Folders:\n', 's');

% Determining the prefix/suffix to assist in locating the preprocessed file
a = input("Does your most preprocessed file name include a prefix or a suffix? Input 'P' for a prefix convention and a 'S' for a suffix convention.\n", 's');

if a == 'P'
    tag = input("What is the prefix of your most preprocessed file?\n-->Example: For the filename 'smooth_norm_stc_realign_sub-00_BOLD.nii', input 'smooth'.\n", 's');
end

if a == 'S'
    tag = input("What is the suffix of your most preprocessed file?\n-->Example: For the filename 'sub-00_BOLD_realign_stc_norm_smooth.nii', input 'smooth'.\n", 's');
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
disp(subjects)

%---------------------------- 1st Analysis -----------------------------%

% Looping through each subject to be analyzed
for subject = subjects
    fprintf('Performing 1st Analysis for %s:\n', subject);


    
end
