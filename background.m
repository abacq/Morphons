folderIn = '/DATA/public/data_abacq/charleroi/';
foldersIndices = [38,60,52,53,46,59,29,61,82,49,56,55,71,43,58,66,72,3,35,80,54,23,51,26,24,62,39,32,34,81,47,77,27,40,91,87,89,84,36,83,1,2,90,42,48,98,65,97,31,64,93,74,30];
for folderI = foldersIndices
    display(folderI);
    folder_CBCT = [folderIn num2str(folderI) '/matCBCT/'];

    % Loading for rectum
    filename = [folder_CBCT 'crop_rectum.mat'];
    rectum = load(filename);
    rectum_value = getfield(rectum,'rectumCropped');


    % Loading for bladder
    filename = [folder_CBCT 'crop_bladder.mat'];
    bladder = load(filename);
    bladder_value = getfield(bladder,'bladderCropped');

    % Calculating background
    max_value = max(rectum_value,bladder_value);
    my_background = abs(max_value - 1);

    % Saving background
    save([folder_CBCT 'crop_background.mat'], "my_background");
end