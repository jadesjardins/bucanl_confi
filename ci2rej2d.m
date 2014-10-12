function [rejbool,rejamp] = ci2rej2d(ci)

%nrows=size(ci,1);
%ncols=size(ci,2);
%size(ci)
cisize=size(ci);
rejbool=zeros(cisize(1:3));
rejamp=zeros(cisize(1:3));

%disp(['nrows ci2rej: ', num2str(nrows)])
%disp(['ncols ci2rej: ', num2str(ncols)])

%disp(['ndims ci: ', num2str(ndims(ci))])
%disp(['size ci2rej ci: ',num2str(size(ci))])
%disp(['size ci2rej rejbool: ',num2str(size(rejbool))])
%disp(['size ci2rej rejbool: ',num2str(size(rejamp))])
for i=1:size(ci,1);
    for ii=1:size(ci,2);
        for iii=1:size(ci,3);
            if ci(i,ii,iii,1) > 0 && ci(i,ii,iii,2) > 0
                rejbool(i,ii,iii) = 1;
                rejamp(i,ii,iii) = ci(i,ii,iii,1);
            else if ci(i,ii,iii,1) < 0 && ci(i,ii,iii,2) < 0
                    rejbool(i,ii,iii,1) = -1;
                    rejamp(i,ii,iii,1) = ci(i,ii,iii,2);
                end
            end
        end
    end
end

%disp(['size ci2rej rejbool 2: ',num2str(size(rejbool))])
%disp(['size ci2rej rejbool 2: ',num2str(size(rejamp))])
