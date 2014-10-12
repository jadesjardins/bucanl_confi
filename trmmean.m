function trm_m = trmmean(data,ptrim,dim)

if ptrim > 1;
    ptrim = ptrim/100;
end

if ~exist('dim','var');
    dim = ndims(data);
end

dim_s=dim-1;
dim_t=ndims(data);
dim_r=dim_t-dim_s;

ntotal = size(data,dim);
ntrim = round(ntotal*ptrim);

data_srt = sort(data,dim);


data_srt = shiftdim(data_srt,dim_s);
trm_m = shiftdim(mean(data_srt(ntrim+1:ntotal-ntrim,:,:),1),dim_r);