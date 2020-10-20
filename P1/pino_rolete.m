clear;
clc;
disp("#####################################################################");
disp("REFERENCIAIS/CONVENÇÕES:");
disp("1a. Forças verticais são positivas no sentido do eixo Y.");
disp("1b. Forças horizontais são positivas no sentido do eixo X.");
disp("1c. Torques são positivos no sentido do eixo X.");
disp("1d. Momentos são positivos no sentido anti-horário.");
disp("");
disp("2. Os referencias são adotados todos a partir do início da viga (ou seja, posição 0)")
disp("");
disp("3. Todas as unidades devem estar no SI menos os ângulos que estão em graus");
disp("#####################################################################\n");

function forcaCarregamento = calcForcaCarregamento(carregamento)
  ini = carregamento(1);
  fim = carregamento(2);
  coefs = transpose(carregamento(3:end));
  integral = polyint(coefs);
  forcaCarregamento = polyval(integral, fim) - polyval(integral, ini);
endfunction

function momentoCarregamento = calcMomentoCarregamento(carregamento)
  ini = carregamento(1);
  fim = carregamento(2);
  coefs = transpose(carregamento(3:end));
  coefs = [coefs, 0]
  integral = polyint(coefs);
  momentoCarregamento = -1*(polyval(integral, fim) - polyval(integral, ini));
endfunction

function forcasExternas = getForcas()
  numForcasPontuais = input("Quantas forças pontuais estão sendo aplicadas na viga: ");

  forcasExternas = zeros(numForcasPontuais,3); # [x, fx, fy]

  if (numForcasPontuais > 0)
    disp("");
    disp("Para cada força, digite sua posição na viga, intensidade, ângulo em graus");
    for i = 1:numForcasPontuais
      disp(sprintf("Força %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      angulo = input("Ângulo: ");
      
      fx = intensidade*cos(deg2rad(angulo));
      fy = intensidade*sin(deg2rad(angulo));
      
      forcasExternas(i,:) = [pos;fx;fy]
      
      disp("Força computada com sucesso!");
    endfor
  endif
endfunction


function torques = getTorques()
  numTorques = input("Quantos torques estao sendo aplicados na viga: ");

  torques = zeros(numTorques,2); # [x, intensidade]

  if (numTorques > 0)
    disp("");
    disp("Para cada torque, digite sua posição e sua intensidade - lembrando que se a intensidade é negativa, o torque � tido no sentido oposto do eixo X.");
    for i = 1:numTorques
      disp(sprintf("Torque %d\n", i));
      pos = input("Posição: ");#precisamos da posicao ?
      intensidade = input("Intensidade: ");
      
      torques(i, :) = [pos;intensidade]
      
      disp("Torque computado com sucesso!");
    endfor
  endif
endfunction

function momentos = getMomentos()
  numMomentos = input("Quantos momentos estão sendo aplicados na viga: ");

  momentos = zeros(numMomentos,2); # [x, intensidade]

  if (numMomentos > 0)
    disp("");
    disp("Para cada momento, digite sua posição e sua intensidade - lembrando que se a intensidade é negativa, o momento � tido no sentido hor�rio.");
    for i = 1:numMomentos
      disp(sprintf("Momento %d\n", i));
      pos = input("Posição: ");#precisamos de posicao ?
      intensidade = input("Intensidade: ");
      
      momentos(i, :) = [pos;intensidade]
      
      disp("Momento computado com sucesso!");
    endfor
  endif
endfunction


function carregamentos = getCarregamentos()
  numCarregamentos = input("Quantos carregamentos distribuídos estão sendo aplicados na viga: ");
  n = input("Digite o grau máximo 'n' da função de carregamento: ")
  
  carregamentos = zeros(numCarregamentos, n+3); # [posIni, posFim, coefs]

  if (numCarregamentos > 0)
    disp("");
    disp("Para cada carregamento, digite as suas posições inicial e final e sua função polinomial (em N/m)");
    for i = 1:numCarregamentos
      disp(sprintf("Carregamento %d\n", i));
      posIni = input("Posição inicial: ");
      posFim = input("Posição final: ");
      coefs = input("Coeficientes (seguindo o padrão) [an;an-1;...;a1;a0]:")
      
      carregamentos(i, :) = [posIni;posFim;coefs]
      
      disp("Carregamento computado com sucesso.");
    endfor
  endif
endfunction

tamanhoViga = input("Digite o tamanho da viga: ");
posicaoRolete = input("Digite o ponto aonde está o apoio do tipo rolete : ");
posicaoPino = input("Digite o ponto aonde está o apoio do tipo pino : ");
forcas = getForcas()
torques = getTorques()
momentos = getMomentos()
carregamentos = getCarregamentos()

###############################################
######## CALCULOS PARA O PINO e ROLETE! ###########
###############################################

# 1. Equilibrio de forças na horizontal:
fx = sum(forcas(:,2)); #Forças pontuais
fx_pino = -fx
printf("-----> Fx do apoio tipo pino: %f\n", fx_pino);

# 2. Equilibrio de forças na vertical:
fy=sum(forcas(:,3))

forcasCarregamento = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Forças de carregamento distribuído
  forcasCarregamentos(i) = calcForcaCarregamento(carregamentos(i,:))
  fy = fy + forcasCarregamentos(i);
endfor

fy = -fy

# 3. Equilibrio de momentos usando 0 como referencial:
momento = sum(momentos(:,2));; #soma dos momentos externos

momentoForcasExternas = -1*dot(forcas(:,1), forcas(:, 3))

momento = momento + sum(momentoForcasExternas)

momentosCarregamentos = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Momento do carregamento distribuido
  momentosCarregamentos(i) = calcMomentoCarregamento(carregamentos(i,:))
  momento = momento + momentosCarregamentos(i);
endfor

momento = -momento 

#4.Achando Fy do rolete e Fy do pino com a equacao de equlibrio dos momento e equilibrio das focas na vertical
resultado_sistema= [ 1 , 1 ; -posicaoRolete , -posicaoPino] \ [fy ; momento]  

fy_rolete = resultado_sistema(1)
fy_pino = resultado_sistema(2)
printf("-------->Fy do apoio tipo pino: %f\n", fy_pino);
printf("-------->Fy do apoio tipo rolete: %f\n", fy_rolete);

# 4. Equilibrio de torques:

torque = sum(torques(:,2));
torque = -torque
printf("------->Torque de reacao do apoio tipo pino: %f\n", torque);


######################################
# DIAGRAMA DE ESFORÇOS SOLICITANTES
######################################
# Pontos de interesse
# Sempre escolhemos o lado esquerdo da secção para encontar as forças solicitantes,
# pois ele tem o ponto considerado o nosso referencial 0.
if (fy_rolete)
  forcas = [forcas;[posicaoRolete,0,fy_rolete]]
endif
if (fy_pino)
  forcas = [forcas;[posicaoPino,0,fy_pino]]
endif
if (fx_pino)
  forcas = [forcas;[posicaoPino,fx_pino,0]]
endif
if (torque)
  torques = [torque;[posicaoPino,torque]]
endif
PontosDeInteresse = [unique(vertcat(forcas(:,1),momentos(:,1),carregamentos(:,1),carregamentos(:,2), torques(:,1)))]
g = figure ();
for i = 2:rows(PontosDeInteresse) # começa em 2 pois o primeiro ponto de interesse sempre sera 0.0
  printf("Ponto de interesse: %d\n", i)
  ####################################################################################
  # Calculo V interno  V(interno)(x) = Fy(resultante) - (somatorio(carregamentos(x)))
  ####################################################################################
  F_definidas_y = sum(forcas(forcas(:,1) < PontosDeInteresse(i),:)(:,3)); #foças precisam estar no intervalo (0.0,pontoDeINnteresse(i))
  # Existe a possibilidade de ter dois tipos de carregamentos aqui:
    # -- Dado um intervalo de pontos de interesse, ao fazermos a secção e pegarmos 
    # -- a figura  com referencial 0(lado esquerdo), há a possibilidade de haver 
    # -- outros pontos de interesse que são diferente do atual. Nestes outros pontos 
    # -- pode haver carregamentos que estão definidos em um intervalo e portanto são integraveis. 
    # -- Porém, considerando o ponto de interesse atual, pode existir um carregamento
    # -- que tem integral avaliada de 0 a x sendo pontoAnterior < x < pontoAtual
    # -- Neste caso x também é o ponto em que fizemos a secção na figura.
    # -- Desta forma devemos pegar o somatório dos carregamentos que estão antes 
    # -- do pontoAnterior, pois possuem integral definida. 
    # -- Pode não haver nenhum carregamento também. 
  CarregamentosIntegraveis = carregamentos(carregamentos(:,2)<= PontosDeInteresse(i-1),:);
  ForcaCarregamento = 0;
  for j = 1:rows(CarregamentosIntegraveis)
    ForcaCarregamento = ForcaCarregamento + calcForcaCarregamento(CarregamentosIntegraveis(j,:));
  endfor
  # V interior será calculado posteriormente quando tivermos os valores de x para a integral
  # caso exista carregamento.
  V_interior_parcial = [F_definidas_y + ForcaCarregamento];
  # Esta parte só serve caso exista um carregamento entre os pontos
  # de interesse, pois dessa forma desconheceremos o limite da integral
  V_interior_carregamento_em_x =  carregamentos(carregamentos(:,2) == PontosDeInteresse(i),:);
  
  ########################################################################################
  # Calculo M interno - M(interno)(x) = Mt(resultante) + (somatorio(x*carregamentos(x)))
  ########################################################################################
  MomentoPontual = sum(momentos(momentos(:,1) < PontosDeInteresse(i),:)(:,2)); # momentos precisam estar no intervalo (0.0,pontoAtual)
  MomentoCarregamentos = 0;
  for j = 1:rows(CarregamentosIntegraveis) #Momento do carregamento distribuído
    MomentoCarregamentos = MomentoCarregamentos + calcMomentoCarregamento(CarregamentosIntegraveis(j,:));
  endfor


   MomentoForcasExternas = 0;
  for j = 1:rows(forcas)
    if forcas(j,1) < PontosDeInteresse(j)
      MomentoForcasExternas = MomentoForcasExternas - forcas(j,3)*forcas(j,1)
    endif
  endfor

  # M interior será calculado posteriormente quando tivermos os valores de x para a integral.
  # Este momento interno ainda não considera o momento gerado pelo V interno
  # Este MomentoCarregamento são aqueles gerados por carregamentos anteriores ao ponto de interesse anterior. 
  M_interior_parcial = MomentoPontual + MomentoCarregamentos + MomentoForcasExternas;
  # Esta parte só serve caso exista um carregamento entre os pontos
  # de interesse, pois dessa forma desconheceremos o limite da integral
  M_interior_carregamento_em_x = carregamentos(carregamentos(:,2) == PontosDeInteresse(i),:);
  
  #####################################################
  # Calculo N interno - N(interno)(x) = Fx(resultante)
  #####################################################
  N_interior = - sum(forcas(forcas(:,1) < PontosDeInteresse(i),:)(:,2)); #foças precisam estar no intervalo (0.0,pontoAtual)

  #####################################################
  # Calculo T interno - T(interno)(x) = Tr(resultante)
  #####################################################
  T_interior = - sum(torques(torques(:,1) < PontosDeInteresse(i),:)(:,2)); #foças precisam estar no intervalo (0.0,pontoAtual)
  
  ####################################################################
  # Calculo dos valores da tabela necessario para montar o diagrama
  ####################################################################
  
  # Criando valores de x no intervalo de dois pontos de interesse

  # TODO: MUDAR A DISTANCIA
  X = transpose(linspace(0,tamanhoViga,tamanhoViga*20));
  DadosDoDiagrama_V_x = zeros(rows(X), 1);
  DadosDoDiagrama_M_x = zeros(rows(X), 1);
  for j = 1:rows(X)
      printf("Ponto em x: %d\n", X(j))

    # Se existir carregamento entre os pontos de interesse a integral sera entre o ponto anterior e o x
    if (sum(carregamentos(:,2)==PontosDeInteresse(i))==1) 
      V_interior_carregamento_em_x(1) = carregamentos(carregamentos(:,2)==PontosDeInteresse(i),1); # posIni
      V_interior_carregamento_em_x(2) = X(j);  # posFim
      V_x = -1*(V_interior_parcial + calcForcaCarregamento(V_interior_carregamento_em_x));
      M_interior_carregamento_em_x(1) = carregamentos(carregamentos(:,2)==PontosDeInteresse(i),1); # posIni
      M_interior_carregamento_em_x(2) = X(j) ; # posFim
      M_x = -1*(M_interior_parcial + calcMomentoCarregamento(M_interior_carregamento_em_x) - (V_x * X(j)));
    else
      V_x = -1*V_interior_parcial; 
      M_x = -1*(M_interior_parcial - (V_x * X(j)));
    endif

    printf("V_x: %d\n", V_x)
    printf("M_x: %d\n", M_x)
        
    
    #printf(DadosDoDiagrama_V_x(j));
    DadosDoDiagrama_V_x(j) = [V_x];
    DadosDoDiagrama_M_x(j) = [M_x];
  endfor   
  # plot da função para cada intervalo dos pontos de interesse
  

  subplot(2,1,1);
  hold on;
  xlabel ("x");
  ylabel ("V(x)");
  title ("Forcas de corte");
  plot(X,DadosDoDiagrama_V_x);
  hold off;     
  
  subplot(2,1,2);
  hold on;
  xlabel ("x");
  ylabel ("M(x)");
  title ("Momento interno");
  plot(X,DadosDoDiagrama_M_x);
  hold off;
endfor
print diagramaForcasSolicitantes.pdf;
open diagramaForcasSolicitantes.pdf