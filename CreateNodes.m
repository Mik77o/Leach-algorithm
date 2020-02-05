% Tworzenie wêz³ów sieci na podstawie parametrów
function Nodes = CreateNodes(Network, number_of_nodes, init_energy)
    for i = 1:number_of_nodes
        Nodes(i).xd = rand()*Network.Surface.Width;    %losowanie wspó³rzêdnej x
        Nodes(i).yd = rand()*Network.Surface.Height;     %losowanie wspó³rzêdnej y
        Nodes(i).E = init_energy;
        Nodes(i).G = 0;
        plot(Nodes(i).xd,Nodes(i).yd,'bo');
        text(Nodes(i).xd+10, Nodes(i).yd-10, num2str(i));
        hold on;
    end
end