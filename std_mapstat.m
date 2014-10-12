% std_mapstat() - Confidence interval calculation.
%
% Usage: 
%   >>  STUDY = std_mapstat(ALLEEG,STUDY,options);
%
% Inputs:
%   ALLEEG   -
%   STUDY    - 
%   options  -
%
% Outputs:
%    STUDY   -
%
% Description:
%   eg.
%   std_srgfiler(ALLEEG,STUDY,'intermejdesjardxt','tst','ptrim',.2,'chanlabs','{ALLEEG(1).chanlocs.labels}','nsrgsamps',1000)
%
% See also:
%   pop_mapstat, 

% Copyright (C) <2008>  <James Desjardins> Brock University
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: std_mapstat.m edit history...
%
function STUDY=std_mapstat(STUDY,fnameout,zcrit,trgext,ssstat,subrmtclst,varargin)

%COLLECT AND SET g STRUCTURE FROM VARARGIN KEY/VAL PAIRS...
g = struct(varargin{:});

% Bootstrapping key/val pairs...
try g.localDataPath;     catch, g.localDataPath    = '';         end;
try g.remoteDataPath;    catch, g.remoteDataPath   = '';         end;



% Design structure handling...
cdesign=STUDY.currentdesign;
ncells=length(STUDY.design(cdesign).cell);
nsubjs=length(STUDY.design(cdesign).cases.value);
nIV1s=length(STUDY.design(cdesign).variable(1).value);
nIV2s=length(STUDY.design(cdesign).variable(2).value);

%Build map.Data.dat... 
for cind=1:ncells;
    
    [p,n]=fileparts(STUDY.design(cdesign).cell(cind).filebase);
    %crfname =                 STUDY.design(cdesign).cell(cind).filebase;
    ctrgfname =               [cd,'/',n,'.',trgext];
    
    if subrmtclst        
        ctrgfname=strrep(ctrgfname,g.localDataPath,g.remoteDataPath);
    end
    
    [cfpath,cfname,cfext] =   fileparts(ctrgfname);
    map =                     mapread(ctrgfname,'dat');
%    matdat =                  load([ctrgfname,'.mat']);
    datfname =                fullfile(cfpath,[fnameout,'.',trgext]);
    
    csubj =      STUDY.design(cdesign).cell(cind).case;
%    csubjind =   strmatch(csubj,STUDY.design(cdesign).cases.value,'exact');
    cIV1 =       find(strcmp(STUDY.design(cdesign).cell(cind).value{1},STUDY.design(cdesign).variable(1).value));
%    cIV1ind =    strmatch(cIV1,STUDY.design(cdesign).variable(1).value);
    cIV2 =       STUDY.design(cdesign).cell(cind).value{2};
%    cIV2ind =    strmatch(cIV2,STUDY.design(cdesign).variable(2).value);
    
    
    cnchs =        size(map.Data.dat,1);
    cntffqs =      size(map.Data.dat,2);
    cnpnts =       size(map.Data.dat,3);
    cnsrgsamps =   size(map.Data.dat,4);

%    cnchs_mat =    size(matdat.icerp,1);
%    cntffqs_mat =  1;
%    cnpnts_mat =   size(matdat.icerp,3);
%    cnsrgsamps_mat =   size(matdat.icerp,4);

    if length(size(map.Data.dat))<5;
        cnmcexps = 1;
    else
        cnmcexps = size(map.Data.dat,5);
    end
    
    if cind==1;
        dat_size=[cnchs,cntffqs,cnpnts,cnsrgsamps,cnmcexps,nsubjs,nIV1s,nIV2s]
%        confimat.ga.erp=zeros([cnchs,cntffqs,cnpnts,1,1,1,nIV1s]);
%        confimat.ga.prct=zeros([cnchs,cntffqs,cnpnts,1,1,1,nIV1s,2]);
    end
    mapwrite(map.Data.dat,datfname,'datsize',dat_size);
    
%    cind
%    size(matdat.icerp)
%    size(confimat.ga.erp)
%    cIV1
%    size(confimat.ga.erp(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1))
%    size(reshape(mean(matdat.icerp,4),size(confimat.ga.erp(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1))))
%    %cumulative measures of location...
%    %confidat.ga.erp
%    confimat.ga.erp(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1)=confimat.ga.erp(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1)+reshape(mean(matdat.icerp,4),size(confimat.ga.erp(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1)));
%    %confidat.ga.ci
%    confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,1)=confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,1)+reshape(prctile(matdat.icerp,5,4),size(confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,1)));
%    confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,2)=confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,2)+reshape(prctile(matdat.icerp,95,4),size(confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,1)));
    
    %confidat.ss.erp
%    confimat.ga.erp(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1)=confimat.ga.erp(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1)+reshape(mean(matdat.icerp,4),size(confimat.ga.erp(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1)));
    %confidat.ga.ci
%    confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,1)=confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,1)+reshape(prctile(matdat.icerp,5,4),size(confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,1)));
%    confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,2)=confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,2)+reshape(prctile(matdat.icerp,95,4),size(confimat.ga.prct(1:cnchs_mat,1:cntffqs_mat,1:cnpnts_mat,1,1,1,cIV1,1)));
    
end

%save('TST_CONFI.mat','confimat');

%CALCULATE CONFIDENCE INTERVALS FOR GRAND AVERAGE DATA USING TST_DAT MATRIX...
clear map
map=mapread(datfname,'dat');
disp(['map.Data.dat size = ', num2str(size(map.Data.dat))])

nchs =        size(map.Data.dat,1);
nfqs =        size(map.Data.dat,2);
npnts =       size(map.Data.dat,3);
nsrgsamps =   size(map.Data.dat,4);
nmcexps =     size(map.Data.dat,5);
nsubjs =      size(map.Data.dat,6);
nIV1s =       size(map.Data.dat,7);
nIV2s =       size(map.Data.dat,8);

%SUBJECTS PRESENT NEEDS TO BE FIXED...
map.Writable=true
nsubjspres=zeros(1,nchs);
for cch=1:nchs;
    for csubj=1:nsubjs;
        %map.Data.dat(cch,1,1,1,1,csubj,:)
        if any(isnan(map.Data.dat(cch,1,1,1,1,csubj,:)))
            %cch
            %csubj
            map.Data.dat(cch,:,:,:,:,csubj,:)=zeros(size(map.Data.dat(cch,:,:,:,:,csubj,:)));
        end
        if ~isequal(map.Data.dat(cch,:,:,:,:,csubj,:),zeros(size(map.Data.dat(cch,:,:,:,:,csubj,:))));
            nsubjspres(cch)=nsubjspres(cch)+1;
        end
    end
end

%ga_sumdat=sum(map.Data.dat,6);
%datsize=[cnchs,cntffqs,cnpnts,cnsrgsamps,cnmcexps,1,nIV1s,nIV2s];
%mapwrite(sum(map.Data.dat,6),'GASUMDAT','datsize',datsize);
%gasumdat=mapread('GASUMDAT','dat');
mapwrite(mean(map.Data.dat,6),[datfname,'.gadat'],'datsize',[cch,nfqs,npnts,nsrgsamps,nmcexps,1,nIV1s,nIV2s]);
gamap=mapread([datfname,'.gadat'],'dat');
% ga_dat(cch,nfqs,npnts,nsrgsamps,nmcexps,1,nIV1s,nIV2s)=sum(map.Data.dat,6)./nsubjspres(cch);
%mapwrite(gasumdat.Data.dat(cch,nfqs,npnts,nsrgsamps,nmcexps,1,nIV1s,nIV2s)./nsubjspres(cch),'GADAT','datsize',datsize);
%gadat=mapread('GADAT','dat');

%ga_dat=ga_sumdat;
%size(ga_dat)
%clear ga_sumdat



%CALCULATE OUTPUT VARIABLES...
disp(['gamap.Data.dat size = ', num2str(size(gamap.Data.dat))])

confidat.ga.erp =    mean(gamap.Data.dat,4);
figure;plot(squeeze(confidat.ga.erp(1,:,:,:,:,:,1)));
hold on;plot(squeeze(confidat.ga.erp(1,:,:,:,:,:,2)),'r');

%allow for multiple IVs...
mapwrite(gamap.Data.dat(:,:,:,:,:,:,1)-gamap.Data.dat(:,:,:,:,:,:,2),[datfname,'.gaddat'],'datsize',[cch,nfqs,npnts,nsrgsamps,nmcexps,1,1,nIV2s]);
clear gamap;
gadmap=mapread([datfname,'.gaddat'],'dat');
%ga.ddat =   ga_dat(:,:,:,:,:,:,1)-ga_dat(:,:,:,:,:,:,2);
%datsize=[cnchs,cntffqs,cnpnts,cnsrgsamps,cnmcexps,1,1,nIV2s];
%mapwrite(gadat.Data.dat(:,:,:,:,:,:,1)-gadat.Data.dat(:,:,:,:,:,:,2);,'GADDAT','datsize',datsize);
%gaddat=mapread('GADDAT','dat');

disp(['gadmap.Data.dat size = ', num2str(size(gadmap.Data.dat))])
confidat.ga.mddat =  mean(gadmap.Data.dat,4);
confidat.ga.sddat =  std(gadmap.Data.dat,0,4);
clear gadmap;

size(confidat.ga.mddat)
size(confidat.ga.sddat)

%ga.mddat =  mean(gaddat.Data.dat,4);
%ga.sddat =  std(gaddat.Data.dat,0,4);

confidat.ga.ci =                   zeros(nchs,nfqs,npnts,1,nmcexps,1,2);
confidat.ga.ci(:,:,:,:,:,:,1) =    confidat.ga.mddat-(confidat.ga.sddat*zcrit);
confidat.ga.ci(:,:,:,:,:,:,2) =    confidat.ga.mddat+(confidat.ga.sddat*zcrit);

[confidat.ga.critdat,confidat.ga.critampdat] =  ci2rejDim7(confidat.ga.ci);
confidat.ga.critzdat =                 confidat.ga.critampdat./confidat.ga.sddat;
confidat.ga.zdat =                     confidat.ga.mddat./confidat.ga.sddat;
%confidat.ga=ga

%eval(['STUDY.', fieldname,'.ga=ga;'])

%CALCULATE CONFIDENCE INTERVALS FOR SINGLE SUBJECTS' DATA USING map.Data.dat MATRIX...
if ssstat
    confidat.ss.erp =mean(map.Data.dat,4);
    mapwrite(map.Data.dat(:,:,:,:,:,:,1)-map.Data.dat(:,:,:,:,:,:,2),[datfname,'.ssddat'],'datsize',[cch,nfqs,npnts,nsrgsamps,nmcexps,nsubjs,1,nIV2s]);
    clear map;
    ssdmap=mapread([datfname,'.ssddat'],'dat');
    %ss.ddat =   map.Data.dat(:,:,:,:,:,:,1)-map.Data.dat(:,:,:,:,:,:,2);
    confidat.ss.mddat =  mean(ssdmap.Data.dat,4);
    confidat.ss.sddat =  std(ssdmap.Data.dat,0,4);
    clear ssdmap;
    confidat.ss.ci =                   zeros(nchs,nfqs,npnts,1,nmcexps,nsubjs,2);
    confidat.ss.ci(:,:,:,:,:,:,1) =    confidat.ss.mddat-confidat.ss.sddat*zcrit;
    confidat.ss.ci(:,:,:,:,:,:,2) =    confidat.ss.mddat+confidat.ss.sddat*zcrit;
    [confidat.ss.critdat,confidat.ss.critampdat] =  ci2rejDim7(confidat.ss.ci);
    confidat.ss.critzdat =                 confidat.ss.critampdat./confidat.ss.sddat;
    confidat.ss.zdat =                     confidat.ss.mddat./confidat.ss.sddat;
end
save([datfname,'.mat'],'confidat');
