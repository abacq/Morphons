is_windows = 0; 

if is_windows
    folderIn = 'F:\data291118\charleroi\';
else
    folderIn = '/DATA/public/data_abacq/namur/';
end

foldersIndices = [119,282,314,188,186,38,198,60,215,226,190,182,8,201,300,59,193,29,231,61,195,290,222,274,286,191,35,54,235,180,14,51,199,26,294,39,210,221,208,309,33,187,168,40,287,236,225,209,184,183,228,229,2,281,295,270,234,204,211,237,278,299,223,230,28,239,212,31,311,37,189,205,19,238,7,185,310,219,312,202,120,30,9,296,179];
% Charleroi : [38,60,52,53,46,59,29,61,82,49,56,55,71,43,58,66,72,3,35,80,54,23,51,26,24,62,39,32,34,81,47,77,27,40,91,87,89,84,36,83,1,2,90,42,48,98,65,97,31,64,93,74,30];
% Namur : [119,282,314,188,186,38,198,60,215,226,190,182,8,201,300,59,193,29,231,61,195,290,222,274,286,191,35,54,235,180,14,51,199,26,294,39,210,221,208,309,33,187,168,40,287,236,225,209,184,183,228,229,2,281,295,270,234,204,211,237,278,299,223,230,28,239,212,31,311,37,189,205,19,238,7,185,310,219,312,202,120,30,9,296,179];

if is_windows
    volumeLimit = load('F:\data291118\charleroi\volumeLimit.mat');
else
    volumeLimit = load('/DATA/public/data_abacq/namur/volumeLimit.mat');
end
volumeLimit_cell = volumeLimit.volumeLimit_cell; 

for folderI = foldersIndices
    display(folderI);
    
    handles = reggui();
        
    format = 3;     % matlab file
    if is_windows
        folder_CBCT = [folderIn num2str(folderI) '\matCBCT\'];
        folder_CT = [folderIn num2str(folderI) '\matCT\'];
    else
        folder_CBCT = [folderIn num2str(folderI) '/matCBCT/'];
        folder_CT = [folderIn num2str(folderI) '/matCT/'];
    end
    
    % Load CT as image and CBCT as data
    handles = Import_image(folder_CBCT,'CBCT',format,'CBCT',handles);
    handles = Import_data(folder_CT,'CT',format,'CT_data',handles);
    
    % Register the CT_data (moving image) on the CBCT (fixed image) and rename it CT
    handles = Registration_ITK_rigid_multimodal('CBCT','CT_data','CT','CT_data_rigid_trans',handles); 
    
%     % Load the unet predictions
%     handles = Empty_image('bladder_dl',handles); 
%     bladder_unet = load([folder_CBCT 'bladder_unet.mat']);
%     bladder_unet_single = single(bladder_unet.bladder_unet);
%     handles.images.data{4} = bladder_unet_single; 
%     handles = Empty_image('rectum_dl',handles); 
%     rectum_unet = load([folder_CBCT 'rectum_unet.mat']);
%     rectum_unet_single = single(rectum_unet.rectum_unet);
%     handles.images.data{5} = rectum_unet_single; 
%     
%     % Load the CT contours and rigid registration
%
    handles = Import_data(folder_CT,'bladder',format,'bladderCT_data',handles);
    handles = Data_deformation('bladderCT_data','CT_data_rigid_trans','bladderCT_rig',handles); 
    handles = Data2image('bladderCT_rig','bladderCT',handles); 
    handles = Import_data(folder_CT,'rectum',format,'rectumCT_data',handles);
    handles = Data_deformation('rectumCT_data','CT_data_rigid_trans','rectumCT_rig',handles); 
    handles = Data2image('rectumCT_rig','rectumCT',handles); 

    % Non rigid registration
    handles = Resample_all(handles,[],[],[2;2;2]);   % downsampling for faster registration
    handles = Registration_modules(1,{'CBCT'},{'CT'},'none',8,[2 5 10 10 10 10 10 10],{4},{1},{[]},{1},1,[],6,3,[1.25 1.25 1.25 1.25 1.25 1.25 1.25 1.25],'CT_def','def_field','',0,handles,1); 
    handles = Deformation('bladderCT','def_field','def_bladderCT',handles);
    handles = Deformation('rectumCT','def_field','def_rectumCT',handles);
    handles = Resample_all(handles,[1;1;1],[465;465;161],[1;1;1]);  % upsampling to original resolution 

    % Threshold the registered CT masks 
    handles = ManualThreshold('bladderCT',[0.5 1.5],'bladderCT_thr',handles);   % threshold output rigid registration
    handles = ManualThreshold('rectumCT',[0.5 1.5],'rectumCT_thr',handles);
    handles = ManualThreshold('def_bladderCT',[0.5 1.5],'def_bladderCT_thr',handles);   % threshold output non-rigid registration
    handles = ManualThreshold('def_rectumCT',[0.5 1.5],'def_rectumCT_thr',handles);
    
    % Export registered contours
    [bladder_morphons,~,~] = Get_reggui_data(handles,'def_bladderCT_thr','images');
    [rectum_morphons,~,~] = Get_reggui_data(handles,'def_rectumCT_thr','images');
    
    % Export additional info
    [def_field_morphons,~,~] = Get_reggui_data(handles,'def_field','fields');
    [def_field_log_morphons,~,~] = Get_reggui_data(handles,'def_field_log','fields');
    [bladder_rigid,~,~] = Get_reggui_data(handles,'bladderCT_thr','images');
    [rectum_rigid,~,~] = Get_reggui_data(handles,'rectumCT_thr','images');
    
    % Export images
    [CT_morphons,~,~] = Get_reggui_data(handles,'CT_def','images');

    % Save
    if is_windows
        save([folderIn  num2str(folderI)  '\matCBCT\CT_morphons.mat'],'CT_morphons');
    else
        %save([folderIn  num2str(folderI)  '/matCBCT/CT_morphons.mat'],'CT_morphons');
        save([folderIn  num2str(folderI)  '/matCBCT/bladder_morphons.mat'],'bladder_morphons');
        save([folderIn  num2str(folderI)  '/matCBCT/rectum_morphons.mat'],'rectum_morphons');
%       save([folderIn  num2str(folderI)  '/matCBCT/bladder_rigid.mat'],'bladder_rigid');
%       save([folderIn  num2str(folderI)  '/matCBCT/rectum_rigid.mat'],'rectum_rigid');
    end
%    mkdir([folderIn 'fields/' num2str(folderI)]);
%     save([folderIn 'fields/' num2str(folderI)  '/field_morphons.mat'],'def_field_morphons','def_field_log_morphons');

    % Crop morphons predictions
    volumeRange = volumeLimit_cell{folderI};
    rangeX = volumeRange{1}; 
    rangeY = volumeRange{2};
    rangeZ = volumeRange{3}
    
    CTdefCropped = CT_morphons(rangeX,rangeY,:);
    if is_windows
        save([folderIn num2str(folderI) '\matCBCT\CT_morphons'],'CTdefCropped');
    else
        save([folderIn num2str(folderI) '/matCBCT' '/CT_morphons_cropped'],'CTdefCropped');
    end
    
    bladderCropped = bladder_morphons(rangeX,rangeY,rangeZ);
    rectumCropped = rectum_morphons(rangeX,rangeY,rangeZ);
    save([folderIn num2str(folderI) '/matCBCT/bladder_morphons'],'bladderCropped');
    save([folderIn num2str(folderI) '/matCBCT/rectum_morphons'],'rectumCropped');
    
    bladderCropped = bladder_rigid(rangeX,rangeY,:);
    rectumCropped = rectum_rigid(rangeX,rangeY,:);
%     save([folderIn 'bladderectum/charleroi/CBCT/' num2str(folderI) '/bladder_rigid'],'bladderCropped');
%     save([folderIn 'bladderectum/charleroi/CBCT/' num2str(folderI) '/rectum_rigid'],'rectumCropped'); 
    
    % Clear 
    clear handles;
end