folderIn = '/DATA/public/data_abacq/charleroi/';
folderIndices = [38,60,52,53,46,59,29,61,82,49,56,55,71,43,58,66,72,3,35,80,54,23,51,26,24,62,39,32,34,81,47,77,27,40,91,87,89,84,36,83,1,2,90,42,48,98,65,97,31,64,93,74,30];



 volumeLimit = load('/DATA/public/data_abacq/charleroi/volumeLimit.mat');
 volumeLimit_cell = volumeLimit.volumeLimit_cell;

 for folderI = folderIndices

    display(folderI)
    % Load the coordinates of the cropped image
    volumeRange = volumeLimit_cell{folderI};
    rangeX = volumeRange{1}; 
    rangeY = volumeRange{2};
    rangeZ = volumeRange{3};

    % Loading our image
    filename = [folderIn num2str(folderI) '/matCBCT/' 'CBCT.mat'];
    CBCT = load(filename);
    image_value = getfield(CBCT,'CBCT');
    
    % Loading for rectum
    filename = [folderIn num2str(folderI) '/matCBCT/' 'rectum.mat'];
    rectum = load(filename);
    rectum_value = getfield(rectum,'contourOAR');


    % Loading for bladder
    filename = [folderIn num2str(folderI) '/matCBCT/' 'bladder.mat'];
    bladder = load(filename);
    bladder_value = getfield(bladder,'contourOAR');
    
    % Loading prediction
    filename = [folderIn num2str(folderI) '/matCBCT/' '/CT_morphons_cropped.mat'];
    pred = load(filename);
    prediction_value = getfield(pred,'CTdefCropped');

    % Save data
    newFolderName = [folderIn  num2str(folderI) '/matCBCT/'];
    
    contourOAR = bladder_value(rangeX,rangeY,rangeZ);
    save([newFolderName 'crop_bladder3.mat'],'contourOAR');
    contourOAR = rectum_value(rangeX,rangeY,rangeZ);
    save([newFolderName 'crop_rectum3.mat'],'contourOAR');
    CBCTCropped = image_value(rangeX,rangeY,rangeZ);
    save([newFolderName 'crop_CBCT3.mat'],'CBCTCropped');
    predictionCropped = prediction_value(:,:,rangeZ);
    save([newFolderName 'crop_prediction.mat'],'predictionCropped');
    

    
    


 end




