function [] = SaveDPM(model, filename)

fid = fopen(filename, 'w');

fprintf(fid, ['sbin=', num2str(model.sbin), '\n']);
fprintf(fid, ['thresh=', num2str(model.thresh), '\n']);
fprintf(fid, ['interval=', num2str(model.interval), '\n']);
fprintf(fid, ['numblocks=', num2str(model.numblocks), '\n']);
fprintf(fid, ['numcomponents=', num2str(model.numcomponents), '\n']);

% deformation
numDeformation = length(model.defs);
fprintf(fid, ['numDefs=' num2str(numDeformation) '\n']);
for d = 1:numDeformation
    fprintf(fid,  'w=');
    for i = 1:length(model.defs{d}.w)
        fprintf(fid, num2str(model.defs{d}.w(i)));
        if length(model.defs{d}.w) == i
            fprintf(fid,  '\n');
        else
            fprintf(fid,  ',');
        end
    end        
    fprintf(fid, ['blocklabel=' num2str(model.defs{d}.blocklabel) '\n']);
    fprintf(fid, ['anchor=' num2str(model.defs{d}.anchor(1)) ',' num2str(model.defs{d}.anchor(2)) '\n']);
end


fclose(fid);

end

%()()
%('')HAANJU.YOO
