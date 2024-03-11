function [relation,r]= relationwcy(data,p)

[row, col] = size(data);
relation = cell(1,col-1);
for k = 1:col-1
    relation{k}=zeros(row);
end
r = ones(row);
for k=1:col-1
   for i=1:row-1
      for j=i+1:row
          relation{k}(i,j)= exp(-p*abs(data(i,k)- data(j,k)));
      end
   end
   relation{k}=relation{k}+relation{k}'+eye(row);
    r= min(r,relation{k});
end
