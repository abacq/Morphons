
folderIn = 'E:\data_tfe\';     

foldersIndices = [30,23]; %[1 2 3 23 24 26 27 29 30 31 32 34 35 36 38 39 40 42 43 
 %46 47 48 49 51 52 53 54 55 56 58 59 60 61 62 64 65 66 70 71 72 74 77 80 81 82 83 84 87 88 89 90 91 92 93 97 98];

volumeLimit = load('E:\data_tfe\test_volume\volumeLimit.mat');
volumeLimit_cell = volumeLimit.volumeLimit_cell;

for folderI = foldersIndices
        
    % Compute dimensions of the original image
    original_mask_struct = load([folderIn num2str(folderI) '/matCBCT/bladder.mat']);
    original_mask = original_mask_struct.contourOAR;
    sz = size(original_mask);
    bladder_unet = zeros(sz);
    rectum_unet = zeros(sz);
    
    % Load the coordinates of the cropped image
    volumeRange = volumeLimit_cell{folderI};
    rangeX = volumeRange{1}; 
    rangeY = volumeRange{2};
    
    % Load unet predictions
    bladderPred_struct = load([folderIn 'bladderectum/charleroi/CBCT/' num2str(folderI) '/bladder_unet.mat' ]);
    bladderPred = bladderPred_struct.bladderUnetCropped;
    rectumPred_struct = load([folderIn 'bladderectum/charleroi/CBCT/' num2str(folderI) '/rectum_unet.mat' ]);
    rectumPred = rectumPred_struct.rectumUnetCropped;
    
    % Fill binary masks
    bladder_unet(rangeX,rangeY,:) = bladderPred;
    rectum_unet(rangeX,rangeY,:) = rectumPred;
    
    % Save full mask
    save([folderIn num2str(folderI) '/matCBCT/bladder_unet'],'bladder_unet');
    save([folderIn num2str(folderI) '/matCBCT/rectum_unet'],'rectum_unet');

end


