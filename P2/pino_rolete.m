clear;
clc;
disp("#####################################################################");
disp("REFERENCIAIS/CONVENÇÕES:");
disp("1a. Forças verticais são positivas no sentido positivo do eixo Y (de baixo para cima).");
disp("1b. Forças horizontais são positivas no sentido positivo do eixo X (da esquerda para direita).");
disp("Por exemplo, para marcar forças pontuais que são: verticais para cima: usa-se angulo 90; verticais para baixo: usa-se angulo 270; horizontais para direita: usa-se angulo 0; horizontais para esquerda: usa-se angulo 180")
disp("1c. Torques são positivos no sentido positivo do eixo X (para a direita).");
disp("1d. Momentos são positivos no sentido horário.");
disp("1e. Caso forças de carregamento estejam sobrepostas, cabe ao usário fazer a devida soma das funções, separando-o em mais de um carregamento caso seja necessário")
disp("1f. Como adotamos refencial de forças de cima pra baixo como negativo, carregamentos que atuem em cima da barra devem ter valor de sua função negativa")
disp("");
disp("2. Os referencias são adotados todos a partir do início da viga, ou seja, posição (0,0)");
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
  coefs = carregamento(3:end);
  coefs = [coefs, 0];
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
      pos = input("Posição: ");
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
      pos = input("Posição: ");
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

###############################################
######## ENTRADAS! ###########
###############################################
%{
tamanhoViga = input("Digite o tamanho da viga: ");
posicaoRolete = input("Digite o ponto aonde está o apoio do tipo rolete : ");
posicaoPino = input("Digite o ponto aonde está o apoio do tipo pino : ");
forcas = getForcas()
torques = getTorques()
momentos = getMomentos()
carregamentos = getCarregamentos()
%}
tamanhoViga = 6;
posicaoRolete = 6;
posicaoPino = 0;
forcas = zeros(0,3); # [x, fx, fy]
ForcasExternas = zeros(0,3);
torques = zeros(0,2); # [x, intensidade]
momentos = [3,15000]; # [x, intensidade
carregamentos = [3,6,-1000,-3000];
%{
tamanhoViga = 6;
posicaoRolete = 6;
posicaoPino = 0;
forcas = [1.5,0,-10000;4.5,0,-15000]; # [x, fx, fy]
ForcasExternas = [1.5,0,-10000;4.5,0,-15000;];
torques = zeros(0,2); # [x, intensidade]
momentos = zeros(0,2); # [x, intensidade
carregamentos = zeros(0,3);
#carregamentos = [0,9,160,0];
%}
###############################################
######## CALCULOS PARA O PINO e ROLETE! ###########
###############################################

# 1. Equilibrio de forças na horizontal:
fx = sum(forcas(:,2)); #Forças pontuais
fx_pino = -fx;
printf("-----> Fx do apoio tipo pino: %.2f\n", fx_pino);

# 2. Equilibrio de forças na vertical:
fy=sum(forcas(:,3));

forcasCarregamento = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Forças de carregamento distribuído
  forcasCarregamentos(i) = calcForcaCarregamento(carregamentos(i,:));
  fy = fy + forcasCarregamentos(i);
endfor

fy = -fy;

# 3. Equilibrio de momentos usando 0 como referencial:
momento = sum(momentos(:,2)); #soma dos momentos externos

momentoForcasExternas = -1*dot(forcas(:,1), forcas(:, 3));

momento = momento + sum(momentoForcasExternas);

momentosCarregamentos = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Momento do carregamento distribuido
  momentosCarregamentos(i) = calcMomentoCarregamento(carregamentos(i,:));
  momento = momento + momentosCarregamentos(i);
endfor

momento = -momento; 

#4.Achando Fy do rolete e Fy do pino com a equacao de equlibrio dos momento e equilibrio das focas na vertical
resultado_sistema= [ 1 , 1 ; -posicaoRolete , -posicaoPino] \ [fy ; momento]  ;

fy_rolete = resultado_sistema(1);
fy_pino = resultado_sistema(2);
printf("-------->Fy do apoio tipo pino: %.2f\n", fy_pino);
printf("-------->Fy do apoio tipo rolete: %.2f\n", fy_rolete);

# 4. Equilibrio de torques:

torque = sum(torques(:,2));
torque = -torque;
printf("------->Torque de reacao do apoio tipo pino: %.2f\n", torque);


######################################
# DIAGRAMA DE ESFORÇOS SOLICITANTES
######################################
# Pontos de interesse
# Sempre escolhemos o lado esquerdo da secção para encontar as forças solicitantes,
# pois ele tem o ponto considerado o nosso referencial 0.
if (fy_rolete)
  forcas = [forcas;[posicaoRolete,0,fy_rolete]];
endif
if (fy_pino)
  forcas = [forcas;[posicaoPino,0,fy_pino]];
endif
if (fx_pino)
  forcas = [forcas;[posicaoPino,fx_pino,0]];
endif
if (torque)
  torques = [torque;[posicaoPino,torque]];
endif

function f_final = integral_de_singularidade(f)
  f_final = f;
  for i = 1:rows(f)
    if f_final(i,3) < 2
      f_final(i,3) = f_final(i,3) + 1;
    else
      f_final(i,3) = f_final(i,3) + 1;
      f_final(i,1) = f_final(i,1)/f_final(i,3);
    endif
  endfor
endfunction

function resultado = resolve_equacao(f,x)
  resultado = 0;
  for i = 1:rows(f)
    if f(i,3) <= -1
      continue;
    elseif x - 0.01 < f(i,2) 
      continue;
    else
      resultado = resultado + (f(i,1)*((x-0.01 - f(i,2))^f(i,3)));
    endif
  endfor
endfunction
PontosDeInteresse = [unique(vertcat(0.0,forcas(:,1),momentos(:,1),carregamentos(:,1),carregamentos(:,2)))];


# q(x) = [intensidade, inicio, expoente; ...]
q = [];
for i = 1:rows(forcas)
  if forcas(i,3) != 0
    q = [q;[forcas(i,3),forcas(i,1),-1]];
  endif
endfor
for i = 1:rows(momentos)
  q = [q;[momentos(i,2),momentos(i,1),-2]];
endfor
for i = 1:rows(carregamentos)
  coefs = carregamentos(i,3:end);
  for j = columns(coefs):1
    if coefs(j) != 0
      q = [q;[coefs(j),carregamentos(i,1),j-1]];
    endif
  endfor
endfor    
q
#V(x) = integral_de_singularidade(q) = [intensidade, inicio, expoente; ...]
V_x = integral_de_singularidade(q)
M_x = integral_de_singularidade(V_x)

####################################################################
# Calculo dos valores da tabela necessario para montar o diagrama
####################################################################
for i = 2:rows(PontosDeInteresse)  
  # Criando valores de x no intervalo de dois pontos de interesse
  X = transpose(linspace(PontosDeInteresse(i-1),PontosDeInteresse(i),(PontosDeInteresse(i)-PontosDeInteresse(i-1))*4));  
  DadosDoDiagrama_V_x = zeros(rows(X), 1);
  DadosDoDiagrama_M_x = zeros(rows(X), 1);
  for j = 1:rows(X)
    X(j)
    if j == 1
      V = resolve_equacao(V_x, X(j)+0.01);
      M = resolve_equacao(M_x, X(j)+0.01);
    elseif j == rows(X)
      V = resolve_equacao(V_x, X(j)-0.01);
      M = resolve_equacao(M_x, X(j)-0.01);
    else
      V = resolve_equacao(V_x, X(j));
      M = resolve_equacao(M_x, X(j));
    endif
    
        
    #printf(DadosDoDiagrama_V_x(j));
    DadosDoDiagrama_V_x(j) = [V];
    DadosDoDiagrama_M_x(j) = [M];
  endfor 
  printf("aaaaaaaaaaaaaaaaaaaaaaaaaaa")
  # plot da função para cada intervalo dos pontos de interesse
  

  subplot(2,1,1);
  hold on;
  xlabel ("x");
  ylabel ("V(x)");
  title ("Esforço cortante");
  plot(X,DadosDoDiagrama_V_x);
  hold off;     
  
  subplot(2,1,2);
  hold on;
  xlabel ("x");
  ylabel ("M(x)");
  title ("Momento fletor");
  plot(X,DadosDoDiagrama_M_x);
  hold off;
endfor
print diagramaForcasSolicitantes.pdf;
open diagramaForcasSolicitantes.pdf






%{
PontosDeInteresse = [unique(vertcat(forcas(:,1),momentos(:,1),carregamentos(:,1),carregamentos(:,2), torques(:,1)))]
g = figure ();
for i = 2:rows(PontosDeInteresse) # começa em 2 pois o primeiro ponto de interesse sempre sera 0.0
  printf("Ponto de interesse: %d\n", i)
  ####################################################################################
  # Calculo V interno  
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
  V_interior_carregamento_em_x =  carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),:);;
  
  ########################################################################################
  # Calculo M interno 
  ########################################################################################
  MomentoPontual = sum(momentos(momentos(:,1) < PontosDeInteresse(i),:)(:,2)); # momentos precisam estar no intervalo (0.0,pontoAtual)
  MomentoCarregamentos = 0;
  for j = 1:rows(CarregamentosIntegraveis) #Momento do carregamento distribuído
    MomentoCarregamentos = MomentoCarregamentos + calcMomentoCarregamento(CarregamentosIntegraveis(j,:));
  endfor


   MomentoForcasExternas = 0;
  for j = 1:rows(forcas)
    if forcas(j,1) < PontosDeInteresse(i)
      MomentoForcasExternas = MomentoForcasExternas - forcas(j,3)*forcas(j,1)
    endif
  endfor

  # M interior será calculado posteriormente quando tivermos os valores de x para a integral.
  # Este momento interno ainda não considera o momento gerado pelo V interno
  # Este MomentoCarregamento são aqueles gerados por carregamentos anteriores ao ponto de interesse anterior. 
  M_interior_parcial = MomentoPontual + MomentoCarregamentos + MomentoForcasExternas;
  # Esta parte só serve caso exista um carregamento entre os pontos
  # de interesse, pois dessa forma desconheceremos o limite da integral
  M_interior_carregamento_em_x =  carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),:);;
  
  #####################################################
  # Calculo N interno 
  #####################################################
  N_interior = - sum(forcas(forcas(:,1) < PontosDeInteresse(i),:)(:,2)); #foças precisam estar no intervalo (0.0,pontoAtual)

  #####################################################
  # Calculo T interno 
  #####################################################
  T_interior = - sum(torques(torques(:,1) < PontosDeInteresse(i),:)(:,2)); #foças precisam estar no intervalo (0.0,pontoAtual)
  
  ####################################################################
  # Calculo dos valores da tabela necessario para montar o diagrama
  ####################################################################
  
  # Criando valores de x no intervalo de dois pontos de interesse

  X = transpose(linspace(PontosDeInteresse(i-1),PontosDeInteresse(i),(PontosDeInteresse(i)-PontosDeInteresse(i-1))*4));  
  DadosDoDiagrama_V_x = zeros(rows(X), 1);
  DadosDoDiagrama_M_x = zeros(rows(X), 1);
  for j = 1:rows(X)

    if (sum(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i))==1) 
      V_interior_carregamento_em_x(1) = carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),1); # posIni
      V_interior_carregamento_em_x(2) = X(j);  # posFim
      V_x = -1*(V_interior_parcial + calcForcaCarregamento(V_interior_carregamento_em_x));
      M_interior_carregamento_em_x(1) = carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),1); # posIni
      M_interior_carregamento_em_x(2) = X(j) ; # posFim
      M_x = -1*(M_interior_parcial + calcMomentoCarregamento(M_interior_carregamento_em_x) - (V_x * X(j)));
    else
      V_x = -1*V_interior_parcial; 
      M_x = -1*(M_interior_parcial - (V_x * X(j)));
    endif

            
    DadosDoDiagrama_V_x(j) = [V_x];
    DadosDoDiagrama_M_x(j) = [M_x];
  endfor   
  # plot da função para cada intervalo dos pontos de interesse
  

  subplot(2,1,1);
  hold on;
  xlabel ("x");
  ylabel ("V(x)");
  title ("Esforço cortante");
  plot(X,DadosDoDiagrama_V_x);
  hold off;     
  
  subplot(2,1,2);
  hold on;
  xlabel ("x");
  ylabel ("M(x)");
  title ("Momento fletor");
  plot(X,DadosDoDiagrama_M_x);
  hold off;
endfor
print diagramaForcasSolicitantes.pdf;
open diagramaForcasSolicitantes.pdf
%}
