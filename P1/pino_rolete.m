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
  momentoCarregamento = polyval(integral, fim) - polyval(integral, ini);
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
printf("Fx do apoio tipo pino: %f\n", fx);

# 2. Equilibrio de forças na vertical:
fy=sum(forcas(:,3))

forcasCarregamento = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Forças de carregamento distribuído
  forcasCarregamentos(i) = calcForcaCarregamento(carregamentos(i,:))
  fy = fy + forcasCarregamentos(i);
endfor

fy = -fy

# 3. Equilibrio de momentos usando 0 como referencial:
momento = sum(momentos(:2)); #soma dos momentos externos

momentoForcasExternas = dot(forcas(:,1), forcas(:, 3))

momento = momento + sum(momentoForcasExternas)

momentosCarregamentos = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Momento do carregamento distribuido
  momentosCarregamentos(i) = calcMomentoCarregamento(carregamentos(i,:))
  momento = momento + momentosCarregamentos(i);
endfor

momento = -momento

#4.Achando Fy do rolete e Fy do pino com a equacao de equlibrio dos momento e equilibrio das focas na vertical
resultado_sistema= [ 1 , 1 ; posicaoRolete , posicaoPino] \ [fy ; momento]  
fy_rolete = resultado_sistema(1)
fy_pino = resultado_sistema(1)
printf("Fy do apoio tipo pino: %f\n", fy_pino);
printf("Fy do apoio tipo rolete: %f\n", fy_rolete);

# 4. Equilibrio de torques:

torque = sum(torques(:,2));
torque = -torque
printf("Torque de reacao do apoio tipo pino: %f\n", torque);

# TODO: DIAGRAMA DE ESFORÇOS SOLICITANTES


