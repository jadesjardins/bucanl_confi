function [rejbool,rejamp] = ci2rej(ci)

nrows=size(ci,1);
ncols=size(ci,2);

rejbool=zeros(nrows,ncols,1);
rejamp=zeros(nrows,ncols,1);

%disp(['nrows ci2rej: ', num2str(nrows)])
%disp(['ncols ci2rej: ', num2str(ncols)])

%disp(['ndims ci: ', num2str(ndims(ci))])
%disp(['size ci2rej ci: ',num2str(size(ci))])
%disp(['size ci2rej rejbool: ',num2str(size(rejbool))])
%disp(['size ci2rej rejbool: ',num2str(size(rejamp))])
for i=1:nrows;
    for ii=1:ncols;
        if ci(i,ii,1) > 0 && ci(i,ii,2) > 0
            rejbool(i,ii,1) = 1;
            rejamp(i,ii,1) = ci(i,ii,1);
        else if ci(i,ii,1) < 0 && ci(i,ii,2) < 0
                rejbool(i,ii,1) = -1;
                rejamp(i,ii,1) = ci(i,ii,2);
            end
        end
    end
end

%disp(['size ci2rej rejbool 2: ',num2str(size(rejbool))])
%disp(['size ci2rej rejbool 2: ',num2str(size(rejamp))])
