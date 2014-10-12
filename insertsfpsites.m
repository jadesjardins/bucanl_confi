function [EEG,nch] = insertsfpsites(EEG,coordFName,nfids);

fid=fopen(coordFName);

CoordDbl=fread(fid,'char');
CoordStr=char(CoordDbl');

ChNum=0;
CurCR=1;

for i=1:length(CoordDbl)-12;
    if ChNum==0&&CoordDbl(i)==9;
        ChNum=ChNum+1;
        ChLabel{ChNum}=char(CoordDbl(1:i-1)');
    end
    if CoordDbl(i)==10;
        for ii=1:10;
            if CoordDbl(i+ii)==9;
                ChNum=ChNum+1;
                ChLabel{ChNum}=char(CoordDbl(i+1:i+ii-1)');
                break
            end
        end
    end
end


EEG.nbchan=length(ChLabel)-nfids;
nch=EEG.nbchan;

EEG.tmpdata=EEG.data;
EEG.tmpchanlocs=EEG.chanlocs;

if isfield(EEG.tmpchanlocs,'badchan');
    EEG.tmpchanlocs=rmfield(EEG.tmpchanlocs,'badchan');
end

EEG.data=[];
EEG.data=zeros(EEG.nbchan,EEG.pnts,EEG.trials);

for i=1:length(ChLabel)-nfids;
    EEG.chanlocs(nfids+i).labels=ChLabel{nfids+i};
end

switch(nfids)
    case 0
        EEG=pop_chanedit(EEG,  'load',{ coordFName, 'filetype', 'autodetect'});
    case 3
        EEG=pop_chanedit(EEG,  'load',{ coordFName, 'filetype', 'autodetect'}, ...
                                        'changefield',{1, 'datachan',0}, ...
                                        'changefield',{2, 'datachan',0}, ...
                                        'changefield',{3, 'datachan',0});
    case 5
        EEG=pop_chanedit(EEG,  'load',{ coordFName, 'filetype', 'autodetect'}, ...
                                        'changefield',{1, 'datachan',0}, ...
                                        'changefield',{2, 'datachan',0}, ...
                                        'changefield',{3, 'datachan',0}, ...
                                        'changefield',{4, 'datachan',0}, ...
                                        'changefield',{5, 'datachan',0});
end

for i=1:length(EEG.tmpchanlocs);
    EEG.chanlocs(EEG.nbchan+i).labels=EEG.tmpchanlocs(i).labels;
    EEG.chanlocs(EEG.nbchan+i).X=EEG.tmpchanlocs(i).X;
    EEG.chanlocs(EEG.nbchan+i).Y=EEG.tmpchanlocs(i).Y;
    EEG.chanlocs(EEG.nbchan+i).Z=EEG.tmpchanlocs(i).Z;
    EEG.chanlocs(EEG.nbchan+i).sph_theta=EEG.tmpchanlocs(i).sph_theta;
    EEG.chanlocs(EEG.nbchan+i).sph_phi=EEG.tmpchanlocs(i).sph_phi;
    EEG.chanlocs(EEG.nbchan+i).sph_radius=EEG.tmpchanlocs(i).sph_radius;
    EEG.chanlocs(EEG.nbchan+i).theta=EEG.tmpchanlocs(i).theta;
    EEG.chanlocs(EEG.nbchan+i).radius=EEG.tmpchanlocs(i).radius;
    EEG.chanlocs(EEG.nbchan+i).type=EEG.tmpchanlocs(i).type;
%    EEG.chanlocs(EEG.nbchan+i).urchan=EEG.tmpchanlocs(i).urchan;
    
    EEG.data(EEG.nbchan+i,:)=EEG.tmpdata(i,:);
end

EEG.nbchan=length(EEG.chanlocs);