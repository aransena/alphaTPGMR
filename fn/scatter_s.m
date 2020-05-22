function scatter_s(s,c,alpha)
    for i = 1:size(s,2)
        s1 = scatter(s(i).Data(2,:),s(i).Data(3,:),10,c,'filled');
        s1.MarkerFaceAlpha = alpha;     
    end    
end