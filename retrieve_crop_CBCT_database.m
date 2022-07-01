
folderIn = '/DATA/public/data_abacq/charleroi/';    
folderOut = '/DATA/public/data_abacq/charleroi/';                           
slideWidth = [128,256,128]; 
foldersIndices = [38,60,52,53,46,59,29,61,82,49,56,55,71,43,58,66,72,3,35,80,54,23,51,26,24,62,39,32,34,81,47,77,27,40,91,87,89,84,36,83,1,2,90,42,48,98,65,97,31,64,93,74,30];

volumeLimit_cell = cell(1,max(foldersIndices));
all_vol_min = [];
for folderI = foldersIndices
    
    %%%%%%%%%%%%%%
    % Load data
    %%%%%%%%%%%%%%
    
    % Load CT
    subfolderIn = [folderIn num2str(folderI) '/matCBCT/'];
    pCT = load([subfolderIn 'CBCT.mat']);
    pCT = pCT.CBCT;
    inputSize = size(pCT);
        
    % Load contours 
    namesROI = {'patient','bladder','bladder_reg','rectum','rectum_reg'};
    nbROI = length(namesROI);
    existingROI = zeros(1,nbROI);
    contoursTensorSoft = zeros(nbROI,inputSize(1),inputSize(2),inputSize(3));

    for i = 1:nbROI
        contourFile = [subfolderIn namesROI{i} '.mat'];
        if exist(contourFile, 'file') == 2
            contourStruct = load(contourFile);
            contoursTensorSoft(i,:,:,:) = contourStruct.contourOAR;
        end
    end

    % Threshold contours
    contoursTensor = zeros(nbROI,inputSize(1),inputSize(2),inputSize(3));
    contoursTensor(contoursTensorSoft > 0.5) = 1;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Database creation
    %%%%%%%%%%%%%%%%%%%%%%%

    namesOAR = {'bladderectum'}; 
    nbOAR = length(namesOAR);
    for i = 1:nbOAR
        % Get mask of the OAR
        if strcmp(namesOAR{i},'bladderectum')
            contours_bladder = squeeze(contoursTensor(2,:,:,:));
            contours_rectum = squeeze(contoursTensor(4,:,:,:));
            contours = contours_bladder | contours_rectum;
        end
        if strcmp(namesOAR{i},'bladder')
            contours = squeeze(contoursTensor(2,:,:,:));
        end
        if strcmp(namesOAR{i},'rectum')
            contours = squeeze(contoursTensor(4,:,:,:));
        end

        % If the mask exists, create the database
        if max(contours(:)) == 1
            % Crop at 192 x 192 x :
            projX = sum(squeeze(sum(contours,3)),2);
            minX = find(projX,1);
            maxX = find(projX,1,'last');
            projY = sum(squeeze(sum(contours,1)),2);
            minY = find(projY,1);
            maxY = find(projY,1,'last');
            projZ = sum(squeeze(sum(contours,1)),1);
            minZ = find(projZ,1);
            maxZ = find(projZ,1,'last'); 

            %Ce que j'ai ajouté
            vol_min = [maxX-minX maxY-minY maxZ-minZ];
            all_vol_min = [all_vol_min ;vol_min];

            center = floor([minX+maxX minY+maxY minZ+maxZ]/2);
            volumeLimit = zeros(3,2);
            volumeLimit(1,:) = [center(1)-floor(slideWidth(1)/2) center(1)-floor(slideWidth(1)/2)+slideWidth(1)-1];
            volumeLimit(2,:) = [center(2)-floor(slideWidth(2)/2) center(2)-floor(slideWidth(2)/2)+slideWidth(2)-1];
            offset = min(0,center(3)-floor(slideWidth(3)/2) - 1);
            offsett = max(160,center(3)-floor(slideWidth(3)/2)+slideWidth(3) - 1);
            volumeLimit(3,:) = [center(3)-floor(slideWidth(3)/2)-(offset)-(offsett-160) center(3)-floor(slideWidth(3)/2)+slideWidth(3)-1-(offset)-(offsett - 160)];
            volumeRange = {volumeLimit(1,1):volumeLimit(1,2); volumeLimit(2,1):volumeLimit(2,2); volumeLimit(3,1):volumeLimit(3,2)};        
        end     
    end
    volumeLimit_cell{folderI} = volumeRange; 
    display(folderI);
end

new_slideWidth = max(all_vol_min);
display(new_slideWidth)
save('/DATA/public/data_abacq/charleroi/volumeLimit.mat','volumeLimit_cell');

