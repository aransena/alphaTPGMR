function plot_2Dframe(s, sc)
    for i = 1:size(s,2)
        for j = 1:size(s(1,i).p, 2)
            qq = eul2quat(rotm2eul(s(i).p(j).A,'XYZ'));
            qq = quat2tform(qq);
            qq(1:3,4) = [s(i).p(j).b(2), s(i).p(j).b(3), 0]';
            triad('Matrix', qq,'Scale',sc,'LineWidth', 3);
            scatter(s(i).p(j).b(2,1),s(i).p(j).b(3,1),20, 'y','filled')
        end        
    end
end