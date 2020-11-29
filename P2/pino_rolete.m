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


function moduloElasticidade = getModuloElasticidade()
    moduloElasticidade = input("Insira o modulo de elasticidade");
endfunction

function moduloCisalhamento = getModuloCisalhamento()
    moduloCisalhamento = input("Insira o modulo de cisalhamento");
endfunction

function infoFormato = getFormato()
    formato = input("Insira o numero correspondente ao formato da barra. 1 - Retangular. 2 - Circulo. 3 - Coroa circular.");
    if(formato == 1)
      b = input("Insira o valor da largura em metros.");
      h = input("Insira o valor da altura em metros.");
      momentoInerciaEmZ = (b*(power(h,3)))/12;
      momentoIneriaEmY = (h*(power(b,3)))/12;
      momentoInerciaPolar = momentoInerciaEmZ + momentoIneriaEmY;
      areaTransversal = h*b
    elseif(formato == 2)
      d = input("Insira o valor do diametro em metros.");
      momentoInerciaEmZ = (3.14 * (power(d,4)))/64;
      momentoInerciaPolar = (2 * momentoInerciaEmZ);
      areaTransversal = 3.14*(power(d/2,2));
    else
      d_e = input("Insira o valor do diametro externo em metros.");
      d_i = input("Insira o valor do diametro interno em metros.");
      momentoInerciaEmZ = (3.14 * ((power(d_e,4))-(power(d_i,4))))/64;
      momentoInerciaPolar = (2 * momentoInerciaEmZ);
      areaTransversal = 3.14*(power(d_e/2,2)) - 3.14*(power(d_i/2,2));
    endif

    infoFormato = [momentoInerciaEmZ,momentoInerciaPolar,areaTransversal];
endfunction


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

tamanhoViga = input("Digite o tamanho da viga: ");
posicaoRolete = input("Digite o ponto aonde está o apoio do tipo rolete : ");
posicaoPino = input("Digite o ponto aonde está o apoio do tipo pino : ");
forcas = getForcas();
torques = getTorques();
momentos = getMomentos();
carregamentos = getCarregamentos();
moduloCisalhamento = getModuloCisalhamento();
moduloElasticidade = getModuloElasticidade();
infoFormato = getFormato();

%{ EXEMPLOS DA AULA 4
tamanhoViga = 9;
posicaoRolete = 9;
posicaoPino = 0;
forcas = zeros(0,3); # [x, fx, fy]
torques = zeros(0,2); # [x, intensidade]
momentos = zeros(0,2); # [x, intensidade
carregamentos = [0,4.5,-1111.11111111,0;4.5,9.0,-1111.11111111,5000];
infoFormato = [1,1,1];
moduloCisalhamento = 1;
moduloElasticidade = 1;
%}
%{ EXEMPLOS DA AULA 4
tamanhoViga = 6;
posicaoRolete = 6;
posicaoPino = 0;
forcas = [1.5,0,-10000;4.5,0,-15000]; # [x, fx, fy]
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
fy=sum(forcas(:,3))

forcasCarregamento = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Forças de carregamento distribuído
  forcasCarregamentos(i) = calcForcaCarregamento(carregamentos(i,:));
  fy = fy + forcasCarregamentos(i);
endfor

fy = -fy

# 3. Equilibrio de momentos usando 0 como referencial:
momento = sum(momentos(:,2)); #soma dos momentos externos

momentoForcasExternas = -1*dot(forcas(:,1), forcas(:, 3));

momento = momento + sum(momentoForcasExternas);

momentosCarregamentos = zeros(rows(carregamentos),1);
for i = 1:rows(carregamentos) #Momento do carregamento distribuido
  momentosCarregamentos(i) = calcMomentoCarregamento(carregamentos(i,:));
  momento = momento + momentosCarregamentos(i);
endfor

momento = -momento 



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
if (fy_pino)
  forcas = [forcas;[posicaoPino,0,fy_pino]];
endif
if (fy_rolete)
  forcas = [forcas;[posicaoRolete,0,fy_rolete]];
endif
if (fx_pino)
  forcas = [forcas;[posicaoPino,fx_pino,0]];
endif
if (torque)
  torques = [torques;[posicaoRolete,torque]];
endif

# Forma de representar e implementar a integral de singularidade
function f_final = integral_de_singularidade(f)
  f_final = f;
  for i = 1:rows(f)
    if f_final(i,3) < 1
      f_final(i,3) = f_final(i,3) + 1;
    else
      f_final(i,3) = f_final(i,3) + 1;
      f_final(i,1) = f_final(i,1)/f_final(i,3);
    endif
  endfor
endfunction

# Dado a representaçao da função de singularidade e um ponto retorna o valor da função no ponto
function resultado = resolve_equacao(f,x)
  resultado = 0;
  for i = 1:rows(f)
    if f(i,3) <= -1
      continue;
    elseif x < f(i,2) 
      continue;
    else
      resultado = resultado + (f(i,1)*((x - f(i,2))^f(i,3)));
    endif
  endfor
endfunction


PontosDeInteresse = [unique(vertcat(0.0,forcas(:,1),momentos(:,1),carregamentos(:,1),carregamentos(:,2),torques(:,1)))]


# representação do q
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
  for j = 1:columns(coefs)
    if coefs(j) != 0
      q = [q;[coefs(j),carregamentos(i,1),columns(coefs)-j]];
      q = [q;[-1*coefs(j),carregamentos(i,2),columns(coefs)-j]];
    endif
  endfor
endfor

# f_x = [intensidade, inicio, expoente; ...]
f_x = [];
for i = 1:rows(forcas)
  if forcas(i,2) != 0
    f_x = [f_x;[forcas(i,2),forcas(i,1),-1]];
  endif
endfor

#t(x) = [intensidade, inicio, expoente; ...]
t = [];
for i = 1:rows(torques)
  t = [t;[torques(i,2),torques(i,1),-1]];
endfor


#V(x) = integral_de_singularidade(q) = [intensidade, inicio, expoente; ...]
V_x = integral_de_singularidade(q);

#M(x) = integral_de_singularidade(V) = [intensidade, inicio, expoente; ...]
M_x = integral_de_singularidade(V_x);

#Teta(x) = integral_de_singularidade(M) sem a constante = [intensidade, inicio, expoente; ...]
Teta_x = integral_de_singularidade(M_x);

#v(x) = integral_de_singularidade(Teta) sem a constante = [intensidade, inicio, expoente; ...]
v_x = integral_de_singularidade(Teta_x);

#N(x) = integral_de_singularidade(f_x) sem a constante = [intensidade, inicio, expoente; ...]
N_x = integral_de_singularidade(f_x);

#L(x) = integral_de_singularidade(N_x) sem a constante = [intensidade, inicio, expoente; ...]
L_x = integral_de_singularidade(N_x);

#T(x) = integral_de_singularidade(t) sem a constante = [intensidade, inicio, expoente; ...]
T_x = integral_de_singularidade(t);

#TORCAO(x) = integral_de_singularidade(T_x) sem a constante = [intensidade, inicio, expoente; ...]
TORCAO_x = integral_de_singularidade(T_x);


# CALCULO DAS CONSTANTES

# Assumimos a origem com Inclinação igual a 0
constanteTETA = -(resolve_equacao(Teta_x,0+0.000000000000001));

# Utilizamos a posicao do pino para determinar a condicao de contorno e obter a constante de integracao da deflexao
constantev = -(resolve_equacao(v_x,posicaoPino+0.000000000000001) + constanteTETA*posicaoPino);

# Utilizamos a posicao do pino para determinar a condicao de contorno e obter a constante do alongamento
constanteL = -(resolve_equacao(L_x,posicaoPino+0.000000000000001));

# Utilizamos a posicao do pino para determinar a condicao de contorno e obter a constante do angulo de torcao
constanteTORCAO = -(resolve_equacao(TORCAO_x,posicaoPino+0.000000000000001));

# As constantes são utilizadas para o cálculo de cada ponto no gráfico.


####################################################################
# Calculo dos valores da tabela necessario para montar o diagrama
####################################################################
for i = 2:rows(PontosDeInteresse)  
  # Criando valores de x no intervalo de dois pontos de interesse
  X = transpose(linspace(PontosDeInteresse(i-1),PontosDeInteresse(i),max((PontosDeInteresse(i)-PontosDeInteresse(i-1))*4,2)));
  DadosDoDiagrama_V_x = zeros(rows(X), 1);
  DadosDoDiagrama_M_x = zeros(rows(X), 1);
  DadosDoDiagrama_N_x = zeros(rows(X), 1);
  DadosDoDiagrama_T_x = zeros(rows(X), 1);
  DadosDoDiagrama_TETA_x = zeros(rows(X), 1);
  DadosDoDiagrama_v_x = zeros(rows(X), 1);
  DadosDoDiagrama_L_x = zeros(rows(X), 1);
  DadosDoDiagrama_TORCAO_x = zeros(rows(X), 1);


  for j = 1:rows(X)
    x = X(j);
    if j == 1
      V = resolve_equacao(V_x, X(j)+0.000000000000001);
      M = resolve_equacao(M_x, X(j)+0.000000000000001);
      N = resolve_equacao(N_x, X(j)+0.000000000000001);
      T = resolve_equacao(T_x, X(j)+0.000000000000001);
      TETA = ((resolve_equacao(Teta_x,X(j)+0.000000000000001))+constanteTETA) * (1/(moduloElasticidade*infoFormato(1)));
      v = ((resolve_equacao(v_x,X(j)+0.000000000000001))+ constantev + constanteTETA*X(j)) * (1/(moduloElasticidade*infoFormato(1)));
      L = ((resolve_equacao(L_x,X(j)+0.000000000000001)) + constanteL) * (1/(moduloElasticidade*infoFormato(3)));
      TORCAO = ((resolve_equacao(TORCAO_x,X(j)+0.000000000000001)) + constanteTORCAO) * (1/(moduloCisalhamento*infoFormato(2)));

    elseif j == rows(X)
      V = resolve_equacao(V_x, X(j)-0.000000000000001);
      M = resolve_equacao(M_x, X(j)-0.000000000000001);
      N = resolve_equacao(N_x, X(j)-0.000000000000001);
      T = resolve_equacao(T_x, X(j)-0.000000000000001);
      TETA = (resolve_equacao(Teta_x,X(j)-0.000000000000001)+constanteTETA) * (1/(moduloElasticidade*infoFormato(1))) ; 
      v = (resolve_equacao(v_x,X(j)-0.000000000000001)+constantev + constanteTETA*X(j)) * (1/(moduloElasticidade*infoFormato(1)));
      L = (resolve_equacao(L_x,X(j)-0.000000000000001)+constanteL) * (1/(moduloElasticidade*infoFormato(3)));
      TORCAO = (resolve_equacao(TORCAO_x,X(j)-0.000000000000001)+constanteTORCAO) * (1/(moduloCisalhamento*infoFormato(2)));

    else
      V = resolve_equacao(V_x, X(j));
      M = resolve_equacao(M_x, X(j));
      N = resolve_equacao(N_x, X(j));
      T = resolve_equacao(T_x, X(j));
      TETA = (resolve_equacao(Teta_x,X(j))+constanteTETA) * (1/(moduloElasticidade*infoFormato(1)));
      v = (resolve_equacao(v_x,X(j))+constantev + constanteTETA*X(j)) * (1/(moduloElasticidade*infoFormato(1)));
      L = (resolve_equacao(L_x,X(j))+constanteL) * (1/(moduloElasticidade*infoFormato(3)));
      TORCAO = (resolve_equacao(TORCAO_x,X(j))+constanteTORCAO) * (1/(moduloCisalhamento*infoFormato(2)));

    endif

        
    #printf(DadosDoDiagrama_V_x(j));
    DadosDoDiagrama_V_x(j) = [V];
    DadosDoDiagrama_M_x(j) = [M];
    DadosDoDiagrama_N_x(j) = [N];
    DadosDoDiagrama_T_x(j) = [T];
    DadosDoDiagrama_TETA_x(j) = [TETA];
    DadosDoDiagrama_v_x(j) = [v];
    DadosDoDiagrama_L_x(j) = [L];
    DadosDoDiagrama_TORCAO_x(j) = [TORCAO];


  endfor 
  # plot da função para cada intervalo dos pontos de interesse
  

  subplot(4,2,1);
  hold on;
  xlabel ("x");
  ylabel ("V(x)");
  title ("Esforço cortante");
  plot(X,DadosDoDiagrama_V_x);
  hold off;     
  
  subplot(4,2,2);
  hold on;
  xlabel ("x");
  ylabel ("M(x)");
  title ("Momento fletor");
  plot(X,DadosDoDiagrama_M_x);
  hold off;

  subplot(4,2,3);
  hold on;
  xlabel ("x");
  ylabel ("N(x)");
  title ("Forças normais");
  plot(X,DadosDoDiagrama_N_x);
  hold off;

  subplot(4,2,4);
  hold on;
  xlabel ("x");
  ylabel ("T(x)");
  title ("Torques internos");
  plot(X,DadosDoDiagrama_T_x);
  hold off;

  subplot(4,2,5);
  hold on;
  xlabel ("x");
  ylabel ("0(x)");
  title ("Inclinação");
  plot(X,DadosDoDiagrama_TETA_x);
  hold off;

  subplot(4,2,6);
  hold on;
  xlabel ("x");
  ylabel ("v(x)");
  title ("Deflexao");
  plot(X,DadosDoDiagrama_v_x);
  hold off;

  subplot(4,2,7);
  hold on;
  xlabel ("x");
  ylabel ("L(x)");
  title ("Alongamento");
  plot(X,DadosDoDiagrama_L_x);
  hold off;

  subplot(4,2,8);
  hold on;
  xlabel ("x");
  ylabel ("Torcao(x)");
  title ("Angulo de Torcao");
  plot(X,DadosDoDiagrama_TORCAO_x);
  hold off;
endfor
print diagramaForcasSolicitantes.pdf;
open diagramaForcasSolicitantes.pdf
