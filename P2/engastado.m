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
disp("O engaste será sempre localizado na parte esquerda da barra.") 
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
  #como o referencial sempre estará no 0 do eixo x, o carregamento gerará um momento contrário ao seu sinal.
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
      
      forcasExternas(i,:) = [pos;fx;fy];
      
      disp("Força computada com sucesso!\n");
    endfor
  endif
endfunction

function torques = getTorques()
  numTorques = input("Quantos torques estao sendo aplicados na viga: ");

  torques = zeros(numTorques,2); # [x, intensidade]

  if (numTorques > 0)
    disp("");
    disp("Para cada torque, digite sua posição e sua intensidade - lembrando que se a intensidade é negativa, o torque é tido no sentido oposto do eixo X.");
    for i = 1:numTorques
      disp(sprintf("Torque %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      
      torques(i, :) = [pos;intensidade];
      
      disp("Torque computado com sucesso!\n");
    endfor
  endif
endfunction

function momentos = getMomentos()
  numMomentos = input("Quantos momentos estao sendo aplicados na viga: ");

  momentos = zeros(numMomentos,2); # [x, intensidade]

  if (numMomentos > 0)
    disp("");
    disp("Para cada momento, digite sua posição e sua intensidade - lembrando que se a intensidade é negativa, o momento é tido no sentido horário.");
    for i = 1:numMomentos
      disp(sprintf("Momento %d\n", i));
      pos = input("Posição: ");
      intensidade = input("Intensidade: ");
      
      momentos(i, :) = [pos;intensidade];
      
      disp("Momento computado com sucesso!\n");
    endfor
  endif
endfunction


function carregamentos = getCarregamentos()
  numCarregamentos = input("Quantos carregamentos distribuídos estão sendo aplicados na viga: ");
  
  if (numCarregamentos > 0)
    n = input("Digite o grau máximo 'n' da função de carregamento: ")
    carregamentos = zeros(numCarregamentos, n+3); # [posIni, posFim, coefs]

    disp("");
    disp("Para cada carregamento, digite as suas posições inicial e final e sua função polinomial (em N/m)");
    for i = 1:numCarregamentos
      disp(sprintf("Carregamento %d\n", i));
      posIni = input("Posição inicial: ");
      posFim = input("Posição final: ");
      coefs = input("Coeficientes (seguindo o padrão) [an;an-1;...;a1;a0], lembrando que deve-se preencher completamente mesmo quando o coeficiente for 0:");
      
      carregamentos(i, :) = [posIni;posFim;coefs];
      
      disp("Carregamento computado com sucesso.");
    endfor
  else
    carregamentos = zeros(0, 3); # [posIni, posFim, coefs]
  endif
endfunction

###############################################
######## ENTRADA! ###########
###############################################
%{
tamanhoViga = input("Digite o tamanho da viga: ");
forcas = getForcas();
torques = getTorques();
momentos = getMomentos();
carregamentos = getCarregamentos();


if tamanhoViga == 0
  error("Viga inexistente")
endif
%}
%{
tamanhoViga = 9;
forcas = zeros(0,3); # [x, fx, fy]
torques = zeros(0,2); # [x, intensidade]
momentos = zeros(0,2); # [x, intensidade
carregamentos = [0,9,160,0];
%}
tamanhoViga = 9;
forcas = [3,0,5000]; # [x, fx, fy]
ForcasExternas = [3,0,5000];
torques = zeros(0,2); # [x, intensidade]
momentos = zeros(0,2); # [x, intensidade
carregamentos = zeros(0,3);
#carregamentos = [0,9,160,0];

###############################################
######## CÁLCULOS PARA O ENGASTADO! ###########
###############################################

disp("#####################################################################");
disp("Reações de apoio para Apoio fixo ou engastado:");

# 1. Equilibrio de forças na horizontal:
fx = -1*(sum(forcas(:,2))); #Forças pontuais
printf("Fx: %.2f\n", fx);

# 2. Equilibrio de forças na vertical:
forcaCarregamento = 0;
for i = 1:rows(carregamentos) #Forças de carregamento distribuído
  forcaCarregamento = forcaCarregamento + calcForcaCarregamento(carregamentos(i,:));
endfor
fy = -1*(forcaCarregamento + sum(forcas(:,3))); #Forças pontuais
printf("Fy: %.2f\n", fy);
ForcaApoioVertical = fy;

# 3. Equilibrio de torques:
torque = -1*sum(torques(:,2));
printf("Torque: %.2f\n", torque);

# 4. Equilibrio de momentos:
#Momento de carregamento
momentoCarregamento = 0;
for i = 1:rows(carregamentos) #Momento do carregamento distribuído
  xResultante = calcMomentoCarregamento(carregamentos(i,:))/calcForcaCarregamento(carregamentos(i,:));
  momentoCarregamento = momentoCarregamento + xResultante*calcForcaCarregamento(carregamentos(i,:));
endfor

# Momentos pontuais
momentoExterno = sum(momentos(:,2));
#Momentos gerados pelas forças externas 
momento_forcas = -1*(dot(forcas(:,1), forcas(:, 3)));

momento = -1*(momentoExterno + momento_forcas + momentoCarregamento);
printf("Momento: %.2f\n", momento);
MomentoApoio = momento;
disp("#####################################################################\n");

#
######################################
# DIAGRAMA DE ESFORÇOS SOLICITANTES
######################################
# Pontos de interesse
# Sempre escolhemos o lado esquerdo da secção para encontar as forças solicitantes,
# pois ele tem o ponto considerado o nosso referencial 0.
if (fy)
  forcas = [forcas;[0,0,fy]]
endif
if (fx)
  forcas = [forcas;[0,fx,0]]
endif
if (momento)
  momentos = [momentos;[0,momento]]
endif

function integral_de_singularidade(f)
  for i = 1:rows(f)
    if f(i,3) < 2
      f(i,3) = f(i,3) + 1
    endif
    else
      f(i,3) = f(i,3) + 1
      f(i,1) = f(i,1)/f(i,3) 
    endif
endfunction

function resolve_equacao(f,x)
  resultado = 0
  for i = 1:rows(f)
    if f(i,3) <= -1
      continue
    elseif x < f(i,2) 
      continue
    endif
    else
      resultado = f(i,1)*((x - f(i,2))^f(i,3))
endfunction
PontosDeInteresse_VM = [unique(vertcat(0.0,forcas(:,1),momentos(:,1),carregamentos(:,1),carregamentos(:,2)))];


# q(x) = [intensidade, inicio, expoente; ...]
if forcas
  for i = 1:rows(forcas)
    if forcas(i,3) != 0
      q = [q;[forcas(i,3),forcas(i,1),-1]]
    endif
endif
if momentos
  for i = 1:rows(momentos)
    q = [q;[momentos(i,2),momentos(i,1),-2]]
  endfor
endif
if carregamentos
  for i = 1:rows(carregamentos)
    coefs = carregamentos(i,3:end)
    for j = columns(coefs):1
      if coefs(j) != 0
        q = [q;[coefs(j),carregamentos(i,1),j-1]]
      endif
    endfor
  endfor    
endif

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
    V = resolve_equacao(V_x, X(j));
    M = resolve_equacao(M_x, X(j));
        
    #printf(DadosDoDiagrama_V_x(j));
    DadosDoDiagrama_V_x(j) = [V];
    DadosDoDiagrama_M_x(j) = [M];
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
%{
for i = 2:rows(PontosDeInteresse) # começa em 2 pois o primeiro ponto de interesse sempre sera 0.0
  ####################################################################################
  # Calculo V interno  
  ####################################################################################
  F_externas = sum(forcas(forcas(:,1) < PontosDeInteresse(i),:)(:,3)); #foças precisam estar no intervalo (0.0,pontoDeINnteresse(i))
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
  V_interior_parcial = [F_externas + ForcaApoioVertical + ForcaCarregamento];
  # Esta parte só serve caso exista um carregamento entre os pontos
  # de interesse, pois dessa forma desconheceremos o limite da integral
  V_interior_carregamento_em_x =  carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),:);
  
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
    if forcas(j,1) < PontosDeInteresse(j)
      MomentoForcasExternas = MomentoForcasExternas - forcas(j,3)*forcas(j,1)
    endif
  endfor


  # M interior será calculado posteriormente quando tivermos os valores de x para a integral.
  # Este momento interno ainda não considera o momento gerado pelo V interno
  # Este MomentoCarregamento são aqueles gerados por carregamentos anteriores ao ponto de interesse anterior. 
  M_interior_parcial = MomentoPontual + MomentoCarregamentos + MomentoApoio + MomentoForcasExternas;
  # Esta parte só serve caso exista um carregamento entre os pontos
  # de interesse, pois dessa forma desconheceremos o limite da integral

  # definindo carregamentos que estejam entre as secções
  M_interior_carregamento_em_x = carregamentos(carregamentos(:,2)>=PontosDeInteresse(i) && carregamentos(:,1)<PontosDeInteresse(i),:);

  #####################################################
  # Calculo N interno 
  #####################################################
  N_interior = -fx - sum(forcas(forcas(:,1) < PontosDeInteresse(i),:)(:,2)); #foças precisam estar no intervalo (0.0,pontoAtual)

  #####################################################
  # Calculo T interno 
  #####################################################
  T_interior = - torque - sum(torques(torques(:,1) < PontosDeInteresse(i),:)(:,2)); #foças precisam estar no intervalo (0.0,pontoAtual)
  
  ####################################################################
  # Calculo dos valores da tabela necessario para montar o diagrama
  ####################################################################
  
  # Criando valores de x no intervalo de dois pontos de interesse
  X = transpose(linspace(PontosDeInteresse(i-1),PontosDeInteresse(i),(PontosDeInteresse(i)-PontosDeInteresse(i-1))*4));  
  DadosDoDiagrama_V_x = zeros(rows(X), 1);
  DadosDoDiagrama_M_x = zeros(rows(X), 1);
  for j = 1:rows(X)

    # Se existir carregamento entre os pontos de interesse a integral sera entre o ponto anterior e o x
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
        
    
    #printf(DadosDoDiagrama_V_x(j));
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