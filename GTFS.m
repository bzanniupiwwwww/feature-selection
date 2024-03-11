function [feature_select,time1] = GTFS(data,p,delta)
%%%考虑了到考察决策类的距离 （模糊情况）
time1 = cputime;
data = normlize_data(data);
[row,col] = size(data);
[partion,~,cj] = unique(data(:,col));
class_num = length(partion);

class = cell(1,class_num);
for i = 1:class_num
    class{i} = find(cj==i);
end
feature_select = [];
feature_left = 1:col-1;%行向量
[relation,r]= relationwcy(data,p);
relation_int = ones(row);
dd_dist = 1-r+eye(row);

nn = 1:1:row;
for i = 1:row
    for j = 1:class_num 
        ee = ismember(nn,class{j});
        nearest_dis(i,j) = min(dd_dist(i,ee)); %%  找到到考察类Dj的最小距离
        alpah(i,j)  =exp(-1*nearest_dis(i,j) ); %% k为调节参数
    end
end

D = [];
for i = 1: row
    for j = 1:class_num
        D(i,j) = (sum(r(i,class{j})))/sum(r(i,:));
    end 
end




start = 1;
l = 1;
dep = zeros(3,1);
while start
    k = 0;
    pos = zeros(1,length(feature_left));
    
    while k < length(feature_left)
        k = k+1;
        label = feature_left(k);
        relat_temp = min(relation_int,relation{label});
        dd_dist = 1-relat_temp;
        for i = 1:row
            for j = 1:class_num
                low_app(i,j) =min(max(alpah(i,j)*dd_dist(i,:),D(:,j)'));
            end
        end
        pos(k) = sum(max(low_app,[],2))/row;
    end
    if k == 0
        start = 0;
    else
        [max_pos,position] = max(pos);
        if isempty(feature_select)
            feature_select = [feature_select,feature_left(position)];
            max_pos_cur = max_pos;
            relation_int = min(relation_int,relation{feature_left(position)});
             feature_left(position) = [];
        else
            depen_incre = max_pos -max_pos_cur ;
            dep(1,l) = max_pos_cur;
            dep(2,l) = max_pos;
            dep(3,l) = depen_incre;
             l = l+1;

            if depen_incre > delta
                feature_select = [feature_select,feature_left(position)];
                max_pos_cur =  max_pos;
                relation_int = min(relation_int,relation{feature_left(position)});
                feature_left(position) = [];
            else
                start=0;
            end
        end
    end
end
time1=cputime-time1;