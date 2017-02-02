function swaplhsrhs(Lhs,Rhs)

Ax = [Lhs,Rhs];
box = get(Ax,'box');
f = get(Ax(1),'parent');
ch = get(f,'children');
lhsPos = find(ch == Ax(1));
rhsPos = find(ch == Ax(2));
if lhsPos > rhsPos
    ch(lhsPos) = Ax(2);
    ch(rhsPos) = Ax(1);
    set(f,'children',ch);
    axesColor = get(Ax(1),'color');
    set(Ax(2),'color',axesColor,'box',box{1});
    set(Ax(1),'color','none','box',box{2});
end

end