function [rejbool,rejamp] = ci2rejDim7(ci)

nchs =        size(ci,1);
nfqs =        size(ci,2);
npnts =       size(ci,3);
nsrgsamps =   size(ci,4);
nmcexps =     size(ci,5);
nsubjs =      size(ci,6);
nIV1s =       size(ci,7);
nIV2s =       size(ci,8);

rejbool=zeros(nchs,nfqs,npnts,nsrgsamps,nmcexps,nsubjs,1,nIV2s);
rejamp=zeros(nchs,nfqs,npnts,nsrgsamps,nmcexps,nsubjs,1,nIV2s);

for ich=1:nchs;
    for ifq=1:nfqs;
        for ipnt=1:npnts;
            for imc=1:nmcexps
                for isubj=1:nsubjs;
                    for iIV2=1:nIV2s;
                        if ci(ich,ifq,ipnt,1,imc,isubj,1,iIV2) > 0 && ci(ich,ifq,ipnt,1,imc,isubj,2,iIV2) > 0
                            rejbool(ich,ifq,ipnt,1,imc,isubj,1,iIV2) = 1;
                            rejamp(ich,ifq,ipnt,1,imc,isubj,1,iIV2) = ci(ich,ifq,ipnt,1,imc,isubj,1,iIV2);
                        else if ci(ich,ifq,ipnt,1,imc,isubj,1,iIV2) < 0 && ci(ich,ifq,ipnt,1,imc,isubj,2,iIV2) < 0
                                rejbool(ich,ifq,ipnt,1,imc,isubj,1,iIV2) = -1;
                                rejamp(ich,ifq,ipnt,1,imc,isubj,1,iIV2) = ci(ich,ifq,ipnt,1,imc,isubj,2,iIV2);
                            end
                        end
                    end
                end                
            end
        end
    end
end

