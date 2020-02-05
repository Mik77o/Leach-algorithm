%Micha³ Kochmañski
%Damian Ko³odziej

clc;
clear all;
close all;

initial_energy = 0.5;       % Pocz¹tkowa energia wszystkich wêz³ów
rounds_number = 100;        % Liczba rund

nodes_number = 200;         % Liczba wêz³ów
p = 0.1;                    % Procent wêz³ów g³ównych
%m = 0.1;                   % Procent wêz³ów o wy¿szej energii pocz¹tkowej
%alpha = 2;                 % Wspó³czynnik zwiêkszania energii pocz¹tkowej
height = 1000;              % Wysokoœæ obszaru(macierzy) rozmieszczenia wêz³ów
width = 1000;               % Szerokoœæ obszaru(macierzy) rozmieszczenia wêz³ów
Sink.X = 500;               % Wspó³rzêdne x y wêz³a nadrzêdnego(sink)
Sink.Y = 500;

%Eelec=Etx=Erx Eelec
ETX=50*0.000000001; %energia zwi¹zana z transmisj¹ bitu danych
ERX=50*0.000000001; %energia zwi¹zana z odbiorem bitu danych

%Typy wzmacniaczy transmisji (Transmit Amplifier Types), zwi¹zane z odleg³oœci¹ od odbiornika
Efs=    10  *0.000000000001;
Emp=0.0013  *0.000000000001;

%Data Aggregation Energy - energia zwi¹zana z agregacj¹ danych przez g³ówny wêze³ w ka¿dym klastrze
EDA=5*0.000000001;

%obliczanie sta³ej d0 zgodnie z wzorem 
do=sqrt(Efs/Emp);

%Tworzenie przestrzeni do rozmieszczenia wêz³ów
Network = CreateNetwork(height, width, Sink.X, Sink.Y);

%Tworzenie wêz³ów
Nodes = CreateNodes(Network, nodes_number, initial_energy);
%Nodes = CreateNodesForHeterogenity(Network, nodes_number, initial_energy,m,alpha);

%Pytanie czy u¿ytkownik chce wybraæ pocz¹tkowe wêz³y g³ówne?
inpt = input("Czy chcesz wybraæ pocz¹tkowe wêz³y g³ówne? [t/n]",'s');
if isempty(inpt)
    inpt = 'n';
end
users_initial_nodes = false;
if inpt == 't'
    users_initial_nodes = true;
   i = 1;
    next = true;
    while next
        x = input("Proszê podaæ numer wêz³a:");
        initial_nodes(i) = x;
        next_node = input("Kolejny wêze³? [t/n]",'s');
        if isempty(inpt)
            next_node = 'n';
        end
        if next_node == 'n'
            next = false;
        end
        i=i+1;
    end
end


% pêtla g³ówna
for r=1:rounds_number
    dead_nodes_number(r) = 0;
    total_network_energy(r) = 0;
    
    %wypisz aktualn¹ runde
    runda = sprintf('%d',r)
    %operacja dla epoki
    if(mod(r, round(1/p) )==0) %wykonuj co 1/p runde
        for i=1:1:nodes_number
            Nodes(i).G=0; 
        end
    end
    
    %wybieranie wêz³ów g³ównych
    %je¿eli u¿ytkownik wybra³ wêz³y
    if users_initial_nodes
        clusters_number = 1;
        for i=1:1:length(Nodes)
            if any(initial_nodes(:) == i)
                        Clusters(clusters_number).xd = Nodes(i).xd;
                        Clusters(clusters_number).yd = Nodes(i).yd;
                        distanceToSink = sqrt( (Nodes(i).xd-Sink.X )^2 + (Nodes(i).yd-Sink.Y)^2 );
                        Clusters(clusters_number).distanceToSink=distanceToSink;
                        Clusters(clusters_number).id=i;
                        Clusters(clusters_number).color=abs(rand(1,3)-0.2);
                        clusters_number=clusters_number+1;
            end
        end
        users_initial_nodes = false;
    %je¿eli u¿ytkownik nie wybra³ wêz³ów
    else
        clusters_number = 1;
        for i=1:1:length(Nodes)
            if(Nodes(i).E>0)
                total_network_energy(r) = total_network_energy(r)+ Nodes(i).E;
                temp_rand=rand;
                if ( (Nodes(i).G)<=0)
                %Wybór wêz³ów g³ówych
                    if(temp_rand <= (p/(1-p*mod(r,round(1/p)))))     %treshold(próg zostania g³ównym wêz³em)
                        Nodes(i).G = round(1/p)-1;
                        Clusters(clusters_number).xd = Nodes(i).xd;
                        Clusters(clusters_number).yd = Nodes(i).yd;

                        distanceToSink = sqrt( (Nodes(i).xd-Sink.X )^2 + (Nodes(i).yd-Sink.Y)^2 );
                        Clusters(clusters_number).distanceToSink=distanceToSink;
                        Clusters(clusters_number).id=i;
                        Clusters(clusters_number).color=abs(rand(1,3)-0.2);
                        clusters_number=clusters_number+1;

                    end     
                end
            end 
            %zliczanie martwych wêz³ów
            if(Nodes(i).E<=0)
                dead_nodes_number(r) = dead_nodes_number(r)+1;
            end
        end
    end
    
    
    %Obliczanie energii rozpraszanej 
    %Na podstawie artyku³u i tych wzorów
    %4000 - wielkoœæ pakietów w bitach
    for c=1:1:length(Clusters)
        if (Clusters(c).distanceToSink > do)
            Nodes(Clusters(c).id).E = Nodes(Clusters(c).id).E - ( (ETX+EDA)*(4000) + Emp*4000*( Clusters(c).distanceToSink ^4)); 
        end
        if (Clusters(c).distanceToSink <= do)
            Nodes(Clusters(c).id).E = Nodes(Clusters(c).id).E - ( (ETX+EDA)*(4000) + Efs*4000*( Clusters(c).distanceToSink ^2 )); 
        end
        
    end
    
    %rysowanie jeœli istnieje jakiœ klaster
    hold off;
    figure(1);
    if(clusters_number-1 >= 1)
        plot(Sink.X,Sink.Y,'rs','MarkerSize',18); %rysowanie sink'a
        text(Sink.X-19,Sink.Y,'BS'); %rysowanie sink'a
        hold on;    
        for i=1:1:nodes_number
            %Sprawdzanie, czy wêze³ jest matrwy
            if (Nodes(i).E<=0)
                plot(Nodes(i).xd,Nodes(i).yd,'black .','MarkerSize',12);%rysowanie dead node
                hold on;    
            end
            if Nodes(i).E>0
                plot(Nodes(i).xd,Nodes(i).yd,'bo'); %oznaczenie "o" dla zwyk³ych nodes
                hold on;
            end
        end
            
        %rysowanie wêz³ów g³ównych
        for c=1:1:clusters_number-1
            plot(Clusters(c).xd, Clusters(c).yd,'*','Color',Clusters(c).color,'MarkerSize',12); %rysowanie klastra  
            text(Clusters(c).xd+10, Clusters(c).yd-10, num2str(Clusters(c).id));
            hold on;
        end
    end
    
    %Wybieranie wêz³a g³ównego dla wêz³ów na podstawie odleg³oœci 
    for i=1:1:nodes_number
        if (Nodes(i).E>0 )
            min_dis_cluster = 0;
            node_range = (Nodes(i).E / initial_energy) * (height/2);    %zasiêg wêz³a = (aktualna energia / pocz¹tkowa energia) * po³owa wysokoœci przestrzeni
            if(clusters_number-1 >= 1) %jeœli istnieje jakikolwiek klaster
                %wybieranie najbli¿szego g³ównego wêz³a
                min_dis = inf;
                for c=1:1:clusters_number-1
                   c_dis = min(min_dis,sqrt( (Nodes(i).xd-Clusters(c).xd)^2 + (Nodes(i).yd-Clusters(c).yd)^2 ) );
                   if ( c_dis < min_dis && c_dis < node_range)     %uwzglêdniony zasiêg wêz³a
                       min_dis = c_dis;
                       min_dis_cluster = c;
                   end
                end
                if(min_dis_cluster ~= 0)
                    %Zmniejszenie energii wêz³a
                    if (min_dis > do)
                        Nodes(i).E = Nodes(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
                    end
                    if (min_dis <= do)
                        Nodes(i).E = Nodes(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
                    end

                    %Zmniejszenie energii wêz³a g³ównego do którego jest po³¹czony wêze³ "i"
                    if(min_dis>0)
                        Nodes(Clusters(min_dis_cluster).id).E = Nodes(Clusters(min_dis_cluster).id).E- ( (ERX + EDA)*4000 ); 
                    end

                    %rysowanie po³¹czeñ miêdzy wêz³ami a wêz³ami g³ównymi
                    line([Nodes(i).xd, Nodes(Clusters(min_dis_cluster).id).xd],[Nodes(i).yd, Nodes(Clusters(min_dis_cluster).id).yd],'Color',Clusters(min_dis_cluster).color);
                end
            end
        end
    hold on;
    end
end

%rysowanie wykresu wynikowego
r=1:rounds_number;
figure;
plot(r,dead_nodes_number,'k.','LineWidth',2);
xlabel('Czas(Runda)');
ylabel('Liczba martwych wêz³ów');
title('Liczba martwych wêz³ów po czasie');

figure;
plot(r,total_network_energy,'k.','LineWidth',2);
xlabel('Czas(Runda)');
ylabel('Iloœæ energii w sieci');
title('Iloœæ energii w sieci po czasie');


    