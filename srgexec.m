function srgexec(ALLEEG,STUDY,g,cdesign,cind)
cind
% Update dataset waitbar...
%waitbar(cind/nsets,wbseth,['Processing dataset ' num2str(cind) ' of ' num2str(nsets) '...']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE VARIABLES...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create current set variables... 
cset=STUDY.design(cdesign).cell(cind).dataset;

if ~isfield(g,'clustStudyPath');
    [p,n]=fileparts(STUDY.design(cdesign).cell(cind).filebase);
    crfname=[cd,'/',n];
    %crfname=STUDY.design(cdesign).cell(cind).filebase;
else
    crfname=strrep(STUDY.design(cdesign).cell(cind).filebase,g.localStudyPath,g.clustStudyPath);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE DATA ARRAY... 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cdat
if length(cset)>1;
    for i=1:length(cset);
        csetpath=STUDY.datasetinfo(cset(i)).filepath;
        c_tmp.EEG = pop_loadset('filename',STUDY.datasetinfo(cset(i)).filename, ...
                              'filepath',csetpath);
        if i==1;
            tmp.ALLEEG=c_tmp.EEG;
        else
            tmp.ALLEEG(i)=c_tmp.EEG;
        end
    end
    tmp.EEG = pop_mergeset(tmp.ALLEEG, 1:length(tmp.ALLEEG), 1);
else
    if ~isfield(g,'clustStudyPath');
        csetpath=STUDY.datasetinfo(cset).filepath;
    else
        csetpath=strrep(STUDY.datasetinfo(cset).filepath,g.localStudyPath,g.clustStudyPath);
    end
    tmp.EEG = pop_loadset('filename',STUDY.datasetinfo(cset).filename,'filepath',csetpath);
end

cdat=tmp.EEG.data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE DATA PROPERTY VARIABLES...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%npnts, cnpnts...
if isempty(g.pnts)
    g.pnts=[1:ALLEEG(cset(1)).pnts];
end
%npts=length(g.pnts);
cnpnts=length(g.pnts);

%nchs
if ~isempty(g.chlabs)
    if ischar(g.chlabs);
        eval(['chlabs=', g.chlabs ';']);
    else
        chlabs=g.chlabs;
    end
    nchs=length(chlabs);
else
    chlabs={ALLEEG(cset(1)).chanlocs.labels};
    nchs=length(chlabs);
end

%cneps
cneps=size(cdat,3);

%cntfpnts and cntffqs if TF measures seleted...
if strcmp(g.ssersp,'on') || ...
        strcmp(g.ssitc,'on') || ...
        strcmp(g.issersp,'on') || ...
        strcmp(g.issitc,'on') || ...
        strcmp(g.icersp,'on') || ...
        strcmp(g.icitc,'on');
    figure;
    
    if isempty(g.tfopts)
        [ersp,itc,powbase,times,freqs] = newtimef(cdat(1,:,:), ...
            tmp.EEG.pnts, [tmp.EEG.xmin tmp.EEG.xmax]*1000, ...
            tmp.EEG.srate, g.ntfcycs,'freqs',[3 30],'timesout',600);
    else
        [ersp,itc,powbase,times,freqs] = newtimef(cdat(1,:,:), ...
            tmp.EEG.pnts, [tmp.EEG.xmin tmp.EEG.xmax]*1000, ...
            tmp.EEG.srate, g.ntfcycs, g.tfopts);
    end
close(gcf);
    cntfpnts=length(times);
    cntffqs=length(freqs);
end   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADJUST CDAT ARRAY...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Baseline correction...
if ~isempty(g.blpnts);
    cdat=rmbase(cdat,[],g.blpnts);
end
% Reduce data pnts to g.pnts if pnts is specified in opt/val pair...
cdat=cdat(:,g.pnts,:); % NOTE THAT THIS IS PRECEDED BY BASELINE SUBTRACTION...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE REQUESTED DATA SIGNALS/MEASURES...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SCALP SITES... 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cssdat
if strcmp(g.sserp,'on')||strcmp(g.ssersp,'on')||strcmp(g.ssitc,'on')
    cssdat=zeros(nchs,cnpnts,cneps);
    for cch=1:nchs;
        cchi=strmatch(chlabs{cch},{ALLEEG(cset).chanlocs.labels},'exact');
        if ~isempty(cchi);
            cssdat(cch,:,:)=cdat(cchi,:,:);
        end
    end
    
    nsschans=size(cssdat,1);
    
%csstfdat
    csstfdat=[];
    if strcmp(g.ssersp,'on')||strcmp(g.ssitc,'on');
        
        for i=1:nsschans;
            figure;
            
            if isempty(g.tfopts)
                [ersp,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = newtimef(cssdat(i,:,:), ...
                        tmp.EEG.pnts, [tmp.EEG.xmin tmp.EEG.xmax]*1000, ...
                        tmp.EEG.srate, g.ntfcycs,'freqs',[3 30],'timesout',600);
            else
                [ersp,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = newtimef(cssdat(i,:,:), ...
                        tmp.EEG.pnts, [tmp.EEG.xmin tmp.EEG.xmax]*1000, ...
                        tmp.EEG.srate, g.ntfcycs, g.tfopts);
            end
            
            if cind==1;
                save(['tftimes',g.intermext,'.mat'],'times');
                save(['tffreqs',g.intermext,'.mat'],'freqs');
            end
            clear ersp itc powbase times freqs erspboot itcboot
            csstfdat(i,:,:,:)=tfdata;
            %cnfqs=size(cisstfdat,1);
            %cntfpnts=size(cisstfdat,2);
            close(gcf);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INTERPOLATED SCALP SITES... 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%cissdat
cissdat=[];
if strcmp(g.isserp,'on')||strcmp(g.issersp,'on')||strcmp(g.issitc,'on')
    if isempty(g.montfile);
        [fname,fpath]=uigetfile('*.sfp','Select sfp coordinate file:');
        g.montfile=[fpath,fname];
    end
    
    %intrpoptstr=[', ''nfids'', ',num2str(g.nfids), ...
    %         ', ''manual'', ''', g.manual ''''];
    %if ~isempty(g.coreglndmrks);
    %    intrpoptstr=[intrpoptstr,',''coreglndmrks'',' vararg2str(g.coreglndmrks)];
    %end

    %intrpmont method... this is not compatible with combined IV levels...
    intrpcmd=['tmpiss.EEG = interpmont( tmp.EEG, ''' g.montfile ''');'];
    eval(intrpcmd);
    cissdat = tmpiss.EEG.data;
    nisschans=size(cissdat,1);
    
    %Baseline correction...
    if ~isempty(g.blpnts);
        cissdat=rmbase(cissdat,[],g.blpnts);
    end
    
    if ~isempty(g.intermext)
        chanfname=['chanlocs.',g.intermext,'.mat'];
    else
        chanfname='chanlocs.mat';
    end

    chanlocs=tmpiss.EEG.chanlocs(1:g.nisschans);
    save(chanfname,'chanlocs');
    
    clear tmpiss
%cisstfdat
    cisstfdat=[];
    if strcmp(g.issersp,'on')||strcmp(g.issitc,'on');
        
        for i=1:nisschans;
            figure;
            
            if isempty(g.tfopts)
                [ersp,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = newtimef(cissdat(i,:,:), ...
                        tmp.EEG.pnts, [tmp.EEG.xmin tmp.EEG.xmax]*1000, ...
                        tmp.EEG.srate, g.ntfcycs,'freqs',[3 30],'timesout',600);
            else
                [ersp,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = newtimef(cissdat(i,:,:), ...
                        tmp.EEG.pnts, [tmp.EEG.xmin tmp.EEG.xmax]*1000, ...
                        tmp.EEG.srate, g.ntfcycs, g.tfopts);
            end
            
            if cind==1;
                save(['tftimes',g.intermext,'.mat'],'times');
                save(['tffreqs',g.intermext,'.mat'],'freqs');
            end
            clear ersp itc powbase times freqs erspboot itcboot
            cisstfdat(i,:,:,:)=tfdata;
            %cnfqs=size(cisstfdat,1);
            %cntfpnts=size(cisstfdat,2);
            close(gcf);
        end
    end
    cissdat = cissdat(:,g.pnts,:);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INDEPENDENT COMPONENT SIGNALS... cicdat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Update. const should reflect peak weight...

if strcmp(g.icerp,'on')||strcmp(g.icersp,'on')||strcmp(g.icitc,'on')
    %tmpdata=[];
    %tmpdata = (tmp.EEG.icaweights*tmp.EEG.icasphere)*reshape(tmp.EEG.data(tmp.EEG.icachansind,:,:), ...
    %            length(tmp.EEG.icachansind), tmp.EEG.trials*tmp.EEG.pnts);
    %tmpdata = reshape( tmpdata, size(tmpdata,1), tmp.EEG.pnts, tmp.EEG.trials);
    
    %The following needs to be replaced by cell array stored in
    %each dataset... further, this portion should be compatible
    %with the cluster field of the STUDY structure...
    eval(['cicinds={tmp.EEG.' g.icinds '.inds};']);
    nics=length(cicinds);
    
%cicdat
    %cicdat=zeros(tmp.EEG.nbchan,length(g.pnts),cneps,nics+1);
    if strcmp(g.icersp,'on')||strcmp(g.icitc,'on');
        cictfdat=zeros(nics,cntffqs,cntfpnts,cneps);
    end
    for i=1:nics;
        icind=abs(cicinds{i});
        icclustdat(i,:,:)=zeros(1,length(g.pnts),size(tmp.EEG.data,3));
        if ~isempty(icind)
            if icind~=0;
                %for gfa
                tmp.cicEEG = pop_subcomp(tmp.EEG, setdiff(1:size(tmp.EEG.icaweights,1),icind), 0);
                cicgfadat(:,:,:,i)=tmp.cicEEG.data(:,g.pnts,:);
                %
                %for residual
                tmp.cresEEG = pop_subcomp(tmp.EEG,icind,0);
                cicresdat(:,:,:,i)=tmp.cresEEG.data(:,g.pnts,:);
                %
                for cicind=1:length(icind);
                    if icind(cicind)>0;
                        s=1;
                    else
                        s=-1;
                    end
                    %size(icclustdat(i,:,:))
                    %size(tmp.EEG.icaact(icind(cicind),g.pnts,:))
                    %size(sqrt(mean(tmp.EEG.icawinv(:,icind(cicind)).^2,1))*s)
                    icclustdat(i,:,:)=icclustdat(i,:,:)+tmp.EEG.icaact(icind(cicind),g.pnts,:)*(sqrt(mean(tmp.EEG.icawinv(:,icind(cicind)).^2,1))*s);
                end
                icclustdat(i,:,:)=icclustdat(i,:,:)/length(icind);
            else
                %icclustdat=zeros(1,size(tmp.EEG.data,2),size(tmp.EEG.data,3));
            end
        end
        
        %cicdat=icclustdat;
        %Baseline correction...
        if ~isempty(g.blpnts);
            cicdat=rmbase(cicdat,[],g.blpnts);
        end
%cictfdat
        if strcmp(g.icersp,'on')||strcmp(g.icitc,'on');
            if sum(sum(icclustdat(i,:,:)))~=0;
                figure;

                if isempty(g.tfopts)
                    [ersp,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = newtimef(icclustdat(i,:,:), ...
                        tmp.EEG.pnts, [tmp.EEG.xmin tmp.EEG.xmax]*1000, ...
                        tmp.EEG.srate, g.ntfcycs,'freqs',[3 30],'timesout',600);
                else
                    [ersp,itc,powbase,times,freqs,erspboot,itcboot,tfdata] = newtimef(icclustdat(i,:,:), ...
                        tmp.EEG.pnts, [tmp.EEG.xmin tmp.EEG.xmax]*1000, ...
                        tmp.EEG.srate, g.ntfcycs, g.tfopts);
                end
                
                
               
                save(['tftimes',g.intermext,'.mat'],'times');
                save(['tffreqs',g.intermext,'.mat'],'freqs');
                
                clear ersp itc powbase times freqs erspboot itcboot
                cictfdat(i,:,:,:)=tfdata;
                close(gcf);
            else
                cictfdat(i,:,:,:)=zeros(1,cntffqs,cntfpnts,cneps);
            end
        end
    end
    
    %size(cicdat)
    if strcmp(g.icerp,'on');
        %append the gfa of residual...
%        cicindsall=[cicinds{:}];
%        cicindsall=abs(cicindsall);
        %THIS FAILS IF CICINDSALL CONTAINS ALL ICs...
        %tmp.rEEG = pop_subcomp( tmp.EEG, cicindsall(find(cicindsall>0)), 0);
        %cicdat(:,:,:,nics+1)=tmp.rEEG.data(:,g.pnts,:);
%        cicdat(:,:,:,nics+1)=zeros(size(cicdat(:,:,:,nics)));
        
    end
    
    %cicdat=cicdat(:,g.pnts,:,:);
    clear tmpdata
    clear tmp chanlocs

    %disp(['cicdat size = ',num2str(size(cicdat))])
    %figure;plot(squeeze(mean(cicdat,3))')

    
end
%end

clear tmp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BEGIN SURROGATE LOOP STARTING WITH MONTE CARLO LOOP (DEFAULT TO 1)...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Monte Carlo loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for cmce=1:g.nmcexps;
    if g.nmcexps>1;
        
        if cmce==1;
            %Update Monte Carlo waitbar...
            %waitbar(cmce/g.nmcexps,wbmceh,['Performing MonteCarlo experiment ' num2str(cmce) ' of ' num2str(g.nmcexps) '...']);
            
            %Create cdat duplicat (tmp_cdat) used to sample Monte Carlo
            %sets of trials...
            if ~isempty(cdat);tmp_cdat=cdat;end;
            if exist('cicdat','var');tmp_cicdat=cicdat;end;
            if exist('cintdat','var');tmp_cintdat=cintdat;end;
        else
            %Updata Monte Carlo waitbar...
            %waitbar(cmce/g.nmcexps,wbmceh,['Performing MonteCarlo experiment ' num2str(cmce) ' of ' num2str(g.nmcexps) '...']);
            %end
            
            %Randomly select current Monte Carlo sample trial indices...
            cmcind=[];
            cmcind = ceil(rand(1, cneps)*cneps);
            
            %Cretae current Monte Carlo data vectors (c*dat) by selecting trials
            %defined by cmcind...
            if ~isempty(tmp_cdat);cdat=tmp_cdat(:,:,cmcind);end;
            if exist('tmp_cicdat','var');cicdat=tmp_cicdat(:,:,cmcind,:);end;
            if exist('tmp_cintdat','var');cintdat=tmp_cintdat(:,:,cmcind);end;
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Surrogate sample loop (used to calculate bootstrap statistic)...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    i=0;
    for csrg=1:g.nsrgsamps;
        i=i+1;
        %Update surrogate sample waitbar...
        %waitbar(csrg/g.nsrgsamps,wbsrgh,['Producing surrogate sample ' num2str(csrg) ' of ' num2str(g.nsrgsamps) '...']);
        
        %Randomly select current surrogate sample trial indices...
        csrgind=[];
        csrgind = ceil(rand(1, cneps)*cneps);
        if ~isempty(g.nepmax);
            if length(csrgind)>g.nepmax;
                csrgind=csrgind(1:g.nepmax);
            end
        end
        
        %gfa bootstrap...
        if strcmp(g.gfaerp,'on');
            if csrg == 1
                if isempty(g.intermext);
                    gfafname=[crfname,'.srggfaerp'];
                else
                    gfafname=[crfname,'.',g.intermext,'.srggfaerp'];
                end
                gfaerp=zeros(1,1,cnpnts,g.srgwint);
            end
            
            if isempty(g.ptrim);
                gfaerp(:,1,:,i)=std(mean(cdat(:,:,csrgind),3),0,1);
            else
                gfaerp(:,1,:,i)=std(trmmean(cdat(:,:,csrgind),g.ptrim,3),0,1);
            end
            if csrg/g.srgwint==round(csrg/g.srgwint)||csrg==g.nsrgsamps;
                mapwrite(gfaerp,gfafname,'datsize',[1,1,cnpnts,g.nsrgsamps,g.nmcexps]);
                save([gfafname,'.mat'],'gfaerp');
                gfaerp=zeros(1,1,cnpnts,g.srgwint);
            end
        end
        
        %ss bootstrap...
        if strcmp(g.sserp,'on');
            if csrg == 1
                if isempty(g.intermext);
                    ssfname=[crfname,'.srgsserp'];
                else
                    ssfname=[crfname,'.',g.intermext,'.srgsserp'];
                end
                sserp=zeros(nchs,cnpnts,g.srgwint,g.nmcexps);
            end
            
            if isempty(g.ptrim);
                sserp(:,:,i,cmce)=mean(cssdat(:,:,csrgind),3);
            else
                sserp(:,:,i,cmce)=trmmean(cssdat(:,:,csrgind),g.ptrim,3);
            end
            if csrg/g.srgwint==round(csrg/g.srgwint)||csrg==g.nsrgsamps;
                mapwrite(sserp,ssfname,'datsize',[nchs,cnpnts,g.nsrgsamps,g.nmcexps]);
                sserp=zeros(nchs,cnpnts,g.srgwint,g.nmcexps);
            end
        end
        
        if strcmp(g.ssersp,'on')
            if isempty(g.intermext);
                sserspfname=[crfname,'srgssersp'];
            else
                sserspfname=[crfname,'.',g.intermext,'.srgssersp'];
            end
            if isempty(g.ptrim);
                mapwrite(mean(abs(csstfdat(:,:,:,csrgind)),4),sserspfname,'datsize',[nsschans,cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
            else
                mapwrite(trmmean(abs(csstfdat(:,:,:,csrgind)),g.ptrim,4),sserspfname,'datsize',[nsschans,cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
                %mapwrite(trmmean(abs(cictfdat (:,:,:,csrgind)),g.ptrim,4),icerspfname ,'datsize',[nics     ,cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
            end
        end
        if strcmp(g.ssitc,'on')
            if isempty(g.intermext);
                ssitcfname=[crfname,'srgssitc'];
            else
                ssitcfname=[crfname,'.',g.intermext,'.srgssitc'];
            end
            mapwrite(abs(mean(((csstfdat(:,:,:,csrgind,:))./abs(csstfdat(:,:,:,csrgind,:))),4)),ssitcfname,'datsize',[nsschans,cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
        end
        
        
        
        %iss bootstrap...
        if strcmp(g.isserp,'on');
            if csrg == 1
                if isempty(g.intermext);
                    issfname=[crfname,'.srgisserp'];
                else
                    issfname=[crfname,'.',g.intermext,'.srgisserp'];
                end
                isserp=zeros(nisschans,1,cnpnts,g.srgwint,g.nmcexps);
                disp(['size of isserp = ',num2str(size(isserp))]);
            end
            
            if isempty(g.ptrim);
                isserp(:,1,:,i,cmce)=mean(cissdat(:,:,csrgind),3);
            else
                disp(['size of isserp = ',num2str(size(isserp))]);
                isserp(:,1,:,i,cmce)=trmmean(cissdat(:,:,csrgind),g.ptrim,3);
            end
            if csrg/g.srgwint==round(csrg/g.srgwint)||csrg==g.nsrgsamps;
                mapwrite(isserp,issfname,'datsize',[nisschans,1,cnpnts,g.nsrgsamps,g.nmcexps]);
                isserp=zeros(nisschans,1,cnpnts,g.srgwint,g.nmcexps);
            end
        end
        
        
        if strcmp(g.issersp,'on')
            if isempty(g.intermext);
                isserspfname=[crfname,'srgissersp'];
            else
                isserspfname=[crfname,'.',g.intermext,'.srgissersp'];
            end
            if isempty(g.ptrim);
                mapwrite(mean(abs(cisstfdat(:,:,:,csrgind)),4),isserspfname,'datsize',[nisschans,cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
            else
                mapwrite(trmmean(abs(cisstfdat(:,:,:,csrgind)),g.ptrim,4),isserspfname,'datsize',[nisschans,cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
                %mapwrite(trmmean(abs(cictfdat (:,:,:,csrgind)),g.ptrim,4),icerspfname ,'datsize',[nics     ,cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
            end
        end
        if strcmp(g.issitc,'on')
            if isempty(g.intermext);
                issitcfname=[crfname,'srgintitc'];
            else
                issitcfname=[crfname,'.',g.intermext,'.srgintitc'];
            end
            mapwrite(abs(mean(((cisstfdat(:,:,:,csrgind,:))./abs(cisstfdat(:,:,:,csrgind,:))),4)),issitcfname,'datsize',[cnfqs,cntfpnts,g.nisschans,g.nsrgsamps,g.nmcexps]);
        end
        
        %ic bootstrap...
        if strcmp(g.icerp,'on');
            if csrg == 1
                if isempty(g.intermext);
                    icfname=[crfname,'.srgicerp'];
                else
                    icfname=[crfname,'.',g.intermext,'.srgicerp'];
                end
                icerp=zeros(nics,1,cnpnts,g.srgwint);
            end
            
            if isempty(g.ptrim);
                for ici=1:size(cicdat,1);
                    icerp(ici,1,:,i)=std(mean(squeeze(cicdat(:,:,csrgind,ici)),3),[],1);
                    %icerp(ici,1,:,csrg)=mean(squeeze(cicdat(ici,:,:,csrgind)),2);
                end
            else
                for ici=1:size(icclustdat,1);
                    %size(icerp)
                    %size(cicdat)
                    %size(trmmean(squeeze(cicdat(ici,:,csrgind)),g.ptrim,2))
                    %size(csrgind)
                    %figure;plot(csrgind)
                    %figure;plot(trmmean(squeeze(cicdat(ici,:,csrgind)),g.ptrim,2))
                    icgfa(ici,1,:,i)=std(trmmean(squeeze(cicgfadat(:,:,csrgind,ici)),g.ptrim,3),[],1);
                    icerp(ici,1,:,i)=trmmean(icclustdat(ici,:,csrgind),g.ptrim,3);
                    %icerp(ici,1,:,csrg)=trmmean(squeeze(cicdat(ici,:,csrgind)),g.ptrim,2);
                    %figure;plot(squeeze(icerp(ici,1,:,csrg)))
                    %return
                end
                icres(1,1,:,i)=std(trmmean(squeeze(cicresdat(:,:,csrgind,1)),g.ptrim,3),[],1);
            end
            if csrg/g.srgwint==round(csrg/g.srgwint)||csrg==g.nsrgsamps;
                mapwrite(icerp,icfname,'datsize',[nics,1,cnpnts,g.nsrgsamps,g.nmcexps]);
                try save([icfname,'.mat'],'icerp','-append');catch;save([icfname,'.mat'],'icerp');end
                icerp=zeros(nics,1,cnpnts,g.srgwint);
            end
            if csrg/g.srgwint==round(csrg/g.srgwint)||csrg==g.nsrgsamps;
                mapwrite(icgfa,[icfname,'G'],'datsize',[nics,1,cnpnts,g.nsrgsamps,g.nmcexps]);
                try save([icfname,'G','.mat'],'icgfa','-append');catch;save([icfname,'G','.mat'],'icgfa');end
                icgfa=zeros(nics,1,cnpnts,g.srgwint);
            end
            if csrg/g.srgwint==round(csrg/g.srgwint)||csrg==g.nsrgsamps;
                mapwrite(icres,[icfname,'R'],'datsize',[1,1,cnpnts,g.nsrgsamps,g.nmcexps]);
                try save([icfname,'R','.mat'],'icres','-append');catch;save([icfname,'R','.mat'],'icres');end
                icres=zeros(1,1,cnpnts,g.srgwint);
            end
        end
        if strcmp(g.icersp,'on');
            if isempty(g.intermext);
                icerspfname=[crfname,'.srgicersp'];
            else
                icerspfname=[crfname,'.',g.intermext,'.srgicersp'];
            end
            if isempty(g.ptrim);
                mapwrite(mean(abs(cictfdat(:,:,:,csrgind)),4),icerspfname,'datsize',[nics,cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
                %if csrg==1;
                %    figure;surf(squeeze(mean(abs(cictfdat(1,:,:,csrgind)),4)));
                %end
            else
                mapwrite(trmmean(abs(cictfdat(:,:,:,csrgind)),g.ptrim,4),icerspfname,'datsize',[nics,cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
                %figure;surf(squeeze(double(trmmean(abs(cictfdat(1,:,:,csrgind)),g.ptrim,4))));
            end
        end
        if strcmp(g.icitc,'on');
            %add phase coupling...
            cicitcdat=cictfdat;
            j=0;
            for nici=1:nics-1;
                for nicii=1:nics-i;
                    j=j+1;
                    cicitcdat(nics+j,:,:,:)=cictfdat(nici,:,:,:).*cictfdat(nici+nicii,:,:,:);
                end
            end
            if isempty(g.intermext);
                icitcfname=[crfname,'.srgicitc'];
            else
                icitcfname=[crfname,'.',g.intermext,'.srgicitc'];
            end
            %mapwrite(abs(mean(((cictfdat(:,:,:,csrgind))./abs(cictfdat(:,:,:,csrgind))),4)),icitcfname,'datsize',[size(cictfdat,1),cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
            mapwrite(abs(mean(((cicitcdat(:,:,:,csrgind))./abs(cicitcdat(:,:,:,csrgind))),4)),icitcfname,'datsize',[size(cicitcdat,1),cntffqs,cntfpnts,g.nsrgsamps,g.nmcexps]);
            %figure;surf(squeeze(abs(mean(((cictfdat(1,:,:,csrgind,:))./abs(cictfdat(1,:,:,csrgind,:))),4))));
        end
        
        if csrg/g.srgwint==round(csrg/g.srgwint)||csrg==g.nsrgsamps;
            i=0;
        end
        
    end
end
