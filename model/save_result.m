function save_result(folder,name,result)
if ~exist(folder,'dir'); mkdir(folder); end
result.matlab_version=version;
result.saved_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
root=fileparts(fileparts(mfilename('fullpath')));
files=[dir(fullfile(root,'model','*.m'));dir(fullfile(root,'experiments','*.m'))];
result.source=struct();
result.source_sha256=struct();
for i=1:numel(files)
    code=fileread(fullfile(files(i).folder,files(i).name));
    result.source.(matlab.lang.makeValidName(files(i).name))=code;
    digest=java.security.MessageDigest.getInstance('SHA-256');
    digest.update(uint8(code));
    result.source_sha256.(matlab.lang.makeValidName(files(i).name))=sprintf('%02x',typecast(digest.digest(),'uint8'));
end
save(fullfile(folder,[name '.mat']),'result','-v7');
fprintf('Saved %s\n',fullfile(folder,[name '.mat']));
end
