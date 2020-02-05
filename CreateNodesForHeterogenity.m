function Nodes = CreateNodesForHeterogenity(Network, number_of_nodes, init_energy, m,alpha)
for i = 1:number_of_nodes
    
    temp_rnd=i;
    Nodes(i).xd = rand()*Network.Surface.Height;
    Nodes(i).yd = rand()*Network.Surface.Width;
    Nodes(i).G = 0;
    
    if(temp_rnd>m*number_of_nodes)
        Nodes(i).E = init_energy;
    end
    
    if(temp_rnd<m*number_of_nodes)
        Nodes(i).E = init_energy*alpha;
    end
    
    plot(Nodes(i).xd,Nodes(i).yd,'bo');
    text(Nodes(i).xd+10, Nodes(i).yd-10, num2str(i));
    hold on;
end