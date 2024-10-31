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
% sub- folders location: /Users/nprluser/Documents/AP/Nav_Subjects
% spm12 folder location: /Users/nprluser/Documents/AP/AP_TMS-fMRI
% dcm2niix location:/Library/Frameworks/PythonVersions/3.12/bin/dcm2niix
% Slice Number = 72
% TR = 1.5 s
% Slice Order = Interleaved, Bottom-to-Top
% FWHM: 4
%-------------------------------------------------------------------------

%------------------------ Initializing Variables ------------------------%

% Asking for user input for filepaths
sub_location = input('Path to Parent Directory containing sub- Folders:\n', 's');
spm_location = input('Path to spm12 Folder:\n', 's');
% Type 'where dcm2niix' in Terminal to find this filepath
dcm2niix = input('Path to dcm2niix:\n', 's');

% Adding necessary folders to path
addpath(genpath(spm_location));

% Asking for fMRI specific parameters
disp("fMRI Parameters:");
slices = input('How many slices in the z dimension?\n', 's');
tr = input('What is the repetition time (sec)?\n', 's');

% Converting input to numerical values
slices = str2double(slices);
tr = str2double(tr);
ta = (tr - (tr/slices));

% Asking for info to determine Slice Order
so_ci = input("Is the data Contiguous or Interleaved? Type 'C' for contiguous or 'I' for interleaved.\n", 's');
so_tb = input("Is the slice order Top-to-Bottom or Bottom-to-Top? Type 'T' for Top-to-Bottom or 'B' for Bottom-to-Top.\n", 's');

% Asking for preferred Smoothing Kernel
fwhm_num = input("What is your preferred smoothing kernel (FWHM)? Type as a single number.\n", 's');
fwhm_num = str2double(fwhm_num);
fwhm = [fwhm_num fwhm_num fwhm_num];

% Assigning Slice Order if fMRI data collection is Contiguous
if so_ci == 'C'
    if so_tb == 'B'
        slice_order = 1:slices;
    end
    if so_tb == 'T'
        slice_order = slices:-1:1;
    end
end

% Assigning Slice Order if fMRI data collection is Interleaved
if so_ci == 'I'
    if so_tb == 'B'
        odd_slices = 1:2:slices;
        even_slices = 2:2:slices;
    end
    if so_tb == 'T'
        odd_slices = slices:-2:1;
        even_slices = slices-1:-2:1;
    end
    slice_order = [odd_slices, even_slices];
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

%---------------------------- Preprocessing -----------------------------%

% Looping through each subject to be preprocessed
for subject = subjects
    fprintf('Processing: %s\n', subject);

    subject_func = sprintf('%s/%s/func', sub_location, subject);
    subject_anat = sprintf('%s/%s/anat', sub_location, subject);

    % Checking if functional NIfTI file has been created
    if isfile(sprintf('%s/%s_bold.nii', subject_func, subject)) == 0
        disp('BOLD DICOM files have not been converted to NIfTI. Converting now.');
        % Designating filename for NIfTI file
        filename = sprintf('%s_bold', subject);
        % Creating NIfTI file
        system(sprintf('"%s" -o "%s" -f "%s" "%s"', dcm2niix, subject_func, filename, subject_func'));
    end
    
    % Checking if anatomical NIfTI file has been created
    if isfile(sprintf('%s/%s_t1.nii', subject_anat, subject)) == 0
        disp('T1 DICOM files have not been converted to NIfTI. Converting now.');
        % Designating filename for NIfTI file
        filename = sprintf('%s_t1', subject);
        % Creating NIfTI file
        system(sprintf('"%s" -o "%s" -f "%s" "%s"', dcm2niix, subject_anat, filename, subject_anat'));
    end

    func = sprintf('%s/%s_bold.nii', subject_func, subject);
    anat = sprintf('%s/%s_t1.nii,1', subject_anat, subject);
    
% ----------------------- SPM Preprocessing Batch ----------------------- %
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'Nav_Preproc';
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{func}};

% ---------------------------- Realignment ----------------------------- %
    matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Named File Selector: Nav_Preproc(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1})); 
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'realign_';
    
% ----------------------- Slice Timing Correction ----------------------- %
    matlabbatch{3}.spm.temporal.st.scans{1}(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
    % Number of Slices
    matlabbatch{3}.spm.temporal.st.nslices = slices;
    % Repetition Time
    matlabbatch{3}.spm.temporal.st.tr = tr;
    % Time of Acquisition
    matlabbatch{3}.spm.temporal.st.ta = ta;
    % Slice Order
    matlabbatch{3}.spm.temporal.st.so = slice_order;
    matlabbatch{3}.spm.temporal.st.refslice = 1;
    matlabbatch{3}.spm.temporal.st.prefix = 'stc_';
    
% --------------------------- Coregistration --------------------------- %
    matlabbatch{4}.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
    % Anatomical Reference Image
    matlabbatch{4}.spm.spatial.coreg.estwrite.source = {anat};
    matlabbatch{4}.spm.spatial.coreg.estwrite.other = {''};
    matlabbatch{4}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{4}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{4}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{4}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{4}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{4}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{4}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{4}.spm.spatial.coreg.estwrite.roptions.prefix = 'coreg_';
    
% ---------------------------- Segmentation ---------------------------- %
    matlabbatch{5}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate & Reslice: Coregistered Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
    matlabbatch{5}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{5}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{5}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{5}.spm.spatial.preproc.tissue(1).tpm = {[spm_location '/spm12/tpm/TPM.nii,1']};
    matlabbatch{5}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{5}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(2).tpm = {[spm_location '/spm12/tpm/TPM.nii,2']};
    matlabbatch{5}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{5}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(3).tpm = {[spm_location '/spm12/tpm/TPM.nii,3']};
    matlabbatch{5}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{5}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(4).tpm = {[spm_location '/spm12/tpm/TPM.nii,4']};
    matlabbatch{5}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{5}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(5).tpm = {[spm_location '/spm12/tpm/TPM.nii,5']};
    matlabbatch{5}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{5}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(6).tpm = {[spm_location '/spm12/tpm/TPM.nii,6']};
    matlabbatch{5}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{5}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{5}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{5}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{5}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{5}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{5}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{5}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{5}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{5}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];
    
% --------------------------- Normalisation --------------------------- %
    matlabbatch{6}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{6}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{6}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
    % Updated Voxel Size from 2 to 3 - SPM Documentation
    matlabbatch{6}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
    matlabbatch{6}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{6}.spm.spatial.normalise.write.woptions.prefix = 'norm_';
    
% ----------------------------- Smoothing ----------------------------- %
    matlabbatch{7}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    % Width of Gaussian Kernel
    matlabbatch{7}.spm.spatial.smooth.fwhm = fwhm;
    matlabbatch{7}.spm.spatial.smooth.dtype = 0;
    matlabbatch{7}.spm.spatial.smooth.im = 0;
    matlabbatch{7}.spm.spatial.smooth.prefix = 'smooth_';
    
    % Run the SPM Batch for the subject
    spm_jobman('run', matlabbatch);
    disp([subject ' done']); 
end