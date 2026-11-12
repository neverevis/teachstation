/*
 * Controles de áudio da leitura em voz alta (acessibilidade).
 *
 * Funciona como um "complemento": não altera o código que já lê as questões
 * (quiz-gamificado.js e first-test.html). Ele faz duas coisas:
 *
 *  1. Ao lado de cada botão ".botao-ouvir" coloca um botão de volume (que abre
 *     um controle deslizante vertical) e um rótulo de velocidade ("1x") que abre
 *     um menu de velocidades, no estilo do YouTube.
 *  2. Intercepta window.speechSynthesis.speak para aplicar o volume e a
 *     velocidade escolhidos em qualquer leitura feita pela página.
 *
 * "1x" corresponde à velocidade que a página já usava (rate 0.85); as demais
 * opções multiplicam essa base. Se o usuário mudar algo durante a leitura, ela
 * continua do ponto onde parou já com o novo ajuste.
 */
(function () {
    'use strict';

    if (!('speechSynthesis' in window) || !window.SpeechSynthesisUtterance) {
        return;
    }

    var VELOCIDADES = [0.5, 1, 1.5, 2];
    var CHAVE_VOLUME = 'teachstation.audio.volume';
    var CHAVE_VELOCIDADE = 'teachstation.audio.velocidade';

    var sintese = window.speechSynthesis;
    var falarOriginal = sintese.speak.bind(sintese);

    var ajustes = {
        volume: lerNumero(CHAVE_VOLUME, 1, 0, 1),
        velocidade: lerNumero(CHAVE_VELOCIDADE, 1, 0.5, 2)
    };
    if (VELOCIDADES.indexOf(ajustes.velocidade) === -1) {
        ajustes.velocidade = 1;
    }

    // Leitura em andamento (para poder retomar do ponto atual após um ajuste)
    var leitura = null;
    var reinicioPendente = null;

    // ---------- Preferências do usuário (só conveniência; funciona sem) ----------

    function lerNumero(chave, padrao, min, max) {
        try {
            var valor = parseFloat(window.localStorage.getItem(chave));
            if (!isNaN(valor) && valor >= min && valor <= max) {
                return valor;
            }
        } catch (e) { /* armazenamento indisponível */ }
        return padrao;
    }

    function salvar(chave, valor) {
        try {
            window.localStorage.setItem(chave, String(valor));
        } catch (e) { /* armazenamento indisponível */ }
    }

    // ---------- Interceptação da fala ----------

    function aplicarAjustes(fala) {
        if (typeof fala.__velocidadeBase !== 'number') {
            fala.__velocidadeBase = fala.rate || 1;
        }
        fala.volume = ajustes.volume;
        fala.rate = Math.min(10, Math.max(0.1, fala.__velocidadeBase * ajustes.velocidade));
    }

    function acompanhar(fala, inicio) {
        var registro = {
            fala: fala,
            texto: fala.__textoCompleto || fala.text,
            inicio: inicio,
            indice: inicio
        };
        leitura = registro;
        fala.addEventListener('boundary', function (e) {
            if (leitura === registro && typeof e.charIndex === 'number') {
                registro.indice = registro.inicio + e.charIndex;
            }
        });
        fala.addEventListener('end', function () {
            if (leitura === registro) {
                leitura = null;
            }
        });
    }

    sintese.speak = function (fala) {
        if (fala instanceof window.SpeechSynthesisUtterance) {
            aplicarAjustes(fala);
            if (!fala.__retomada) {
                acompanhar(fala, 0);
            }
        }
        return falarOriginal(fala);
    };

    // Recomeça a leitura atual a partir da última palavra lida, com os novos ajustes
    function retomarComAjustes() {
        clearTimeout(reinicioPendente);
        reinicioPendente = setTimeout(function () {
            if (!leitura || !sintese.speaking || sintese.paused) {
                return;
            }
            var anterior = leitura;
            var restante = anterior.texto.slice(anterior.indice);
            if (!restante.trim()) {
                return;
            }
            var nova = new window.SpeechSynthesisUtterance(restante);
            nova.lang = anterior.fala.lang;
            nova.voice = anterior.fala.voice;
            nova.pitch = anterior.fala.pitch;
            nova.__velocidadeBase = anterior.fala.__velocidadeBase;
            nova.__textoCompleto = anterior.texto;
            nova.__retomada = true;

            leitura = null;
            sintese.cancel();
            acompanharRetomada(nova, anterior);
            sintese.speak(nova);
        }, 250);
    }

    function acompanharRetomada(nova, anterior) {
        var registro = {
            fala: nova,
            texto: anterior.texto,
            inicio: anterior.indice,
            indice: anterior.indice
        };
        leitura = registro;
        nova.addEventListener('boundary', function (e) {
            if (leitura === registro && typeof e.charIndex === 'number') {
                registro.indice = registro.inicio + e.charIndex;
            }
        });
        nova.addEventListener('end', function () {
            if (leitura === registro) {
                leitura = null;
            }
        });
    }

    // ---------- Interface ----------

    var controles = []; // para manter todos os controles da página sincronizados

    function rotuloVelocidade(v) {
        return (v === 2 ? '2.0' : String(v)) + 'x';
    }

    function atualizarTodos() {
        controles.forEach(function (c) { c.atualizar(); });
    }

    function fecharTodos(exceto) {
        controles.forEach(function (c) {
            if (c !== exceto) c.fechar();
        });
    }

    function criarControle(botaoOuvir) {
        var caixa = document.createElement('div');
        caixa.className = 'controle-audio';

        // --- Volume ---
        var grupoVolume = document.createElement('div');
        grupoVolume.className = 'controle-audio-grupo';

        var botaoVolume = document.createElement('button');
        botaoVolume.type = 'button';
        botaoVolume.className = 'controle-audio-botao controle-audio-volume';
        botaoVolume.setAttribute('aria-haspopup', 'true');
        botaoVolume.setAttribute('aria-expanded', 'false');

        var iconeVolume = document.createElement('span');
        iconeVolume.className = 'controle-audio-icone';
        iconeVolume.setAttribute('aria-hidden', 'true');
        botaoVolume.appendChild(iconeVolume);

        var painelVolume = document.createElement('div');
        painelVolume.className = 'controle-audio-painel controle-audio-painel-volume';
        painelVolume.hidden = true;

        var valorVolume = document.createElement('span');
        valorVolume.className = 'controle-audio-valor';

        var deslizante = document.createElement('input');
        deslizante.type = 'range';
        deslizante.min = '0';
        deslizante.max = '100';
        deslizante.step = '5';
        deslizante.className = 'controle-audio-deslizante';
        deslizante.setAttribute('orient', 'vertical'); // Firefox antigo
        deslizante.setAttribute('aria-label', 'Volume da leitura');
        deslizante.setAttribute('aria-orientation', 'vertical');

        painelVolume.appendChild(valorVolume);
        painelVolume.appendChild(deslizante);
        grupoVolume.appendChild(botaoVolume);
        grupoVolume.appendChild(painelVolume);

        // --- Velocidade ---
        var grupoVelocidade = document.createElement('div');
        grupoVelocidade.className = 'controle-audio-grupo';

        var botaoVelocidade = document.createElement('button');
        botaoVelocidade.type = 'button';
        botaoVelocidade.className = 'controle-audio-botao controle-audio-velocidade';
        botaoVelocidade.setAttribute('aria-haspopup', 'menu');
        botaoVelocidade.setAttribute('aria-expanded', 'false');

        var menuVelocidade = document.createElement('div');
        menuVelocidade.className = 'controle-audio-painel controle-audio-menu';
        menuVelocidade.setAttribute('role', 'menu');
        menuVelocidade.setAttribute('aria-label', 'Velocidade da leitura');
        menuVelocidade.hidden = true;

        var tituloMenu = document.createElement('p');
        tituloMenu.className = 'controle-audio-menu-titulo';
        tituloMenu.textContent = 'Velocidade';
        menuVelocidade.appendChild(tituloMenu);

        var opcoes = VELOCIDADES.map(function (v) {
            var opcao = document.createElement('button');
            opcao.type = 'button';
            opcao.className = 'controle-audio-opcao';
            opcao.setAttribute('role', 'menuitemradio');
            opcao.dataset.velocidade = String(v);
            opcao.textContent = v === 1 ? 'Normal (1x)' : rotuloVelocidade(v);
            opcao.addEventListener('click', function () {
                ajustes.velocidade = v;
                salvar(CHAVE_VELOCIDADE, v);
                atualizarTodos();
                fecharMenu(true);
                retomarComAjustes();
            });
            menuVelocidade.appendChild(opcao);
            return opcao;
        });

        grupoVelocidade.appendChild(botaoVelocidade);
        grupoVelocidade.appendChild(menuVelocidade);

        // --- Montagem: o botão original vai para dentro da caixa, sem ser alterado ---
        botaoOuvir.parentNode.insertBefore(caixa, botaoOuvir);
        caixa.appendChild(botaoOuvir);
        caixa.appendChild(grupoVolume);
        caixa.appendChild(grupoVelocidade);

        // --- Comportamento ---
        function abrirVolume() {
            fecharTodos(controle);
            fecharMenu(false);
            painelVolume.hidden = false;
            botaoVolume.setAttribute('aria-expanded', 'true');
            deslizante.focus();
        }

        function fecharVolume(devolverFoco) {
            if (painelVolume.hidden) return;
            painelVolume.hidden = true;
            botaoVolume.setAttribute('aria-expanded', 'false');
            if (devolverFoco) botaoVolume.focus();
        }

        function abrirMenu() {
            fecharTodos(controle);
            fecharVolume(false);
            menuVelocidade.hidden = false;
            botaoVelocidade.setAttribute('aria-expanded', 'true');
            var atual = menuVelocidade.querySelector('[aria-checked="true"]') || opcoes[0];
            atual.focus();
        }

        function fecharMenu(devolverFoco) {
            if (menuVelocidade.hidden) return;
            menuVelocidade.hidden = true;
            botaoVelocidade.setAttribute('aria-expanded', 'false');
            if (devolverFoco) botaoVelocidade.focus();
        }

        botaoVolume.addEventListener('click', function () {
            if (painelVolume.hidden) abrirVolume(); else fecharVolume(false);
        });

        botaoVelocidade.addEventListener('click', function () {
            if (menuVelocidade.hidden) abrirMenu(); else fecharMenu(false);
        });

        deslizante.addEventListener('input', function () {
            ajustes.volume = parseInt(deslizante.value, 10) / 100;
            salvar(CHAVE_VOLUME, ajustes.volume);
            atualizarTodos();
            retomarComAjustes();
        });

        // Setas para navegar no menu de velocidades
        menuVelocidade.addEventListener('keydown', function (e) {
            var i = opcoes.indexOf(document.activeElement);
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                opcoes[(i + 1) % opcoes.length].focus();
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                opcoes[(i - 1 + opcoes.length) % opcoes.length].focus();
            }
        });

        caixa.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                if (!painelVolume.hidden) fecharVolume(true);
                if (!menuVelocidade.hidden) fecharMenu(true);
            }
        });

        var controle = {
            caixa: caixa,
            fechar: function () {
                fecharVolume(false);
                fecharMenu(false);
            },
            atualizar: function () {
                var porcento = Math.round(ajustes.volume * 100);
                botaoVolume.classList.toggle('mudo', ajustes.volume === 0);
                botaoVolume.setAttribute('aria-label', 'Volume da leitura: ' + porcento + '%');
                botaoVolume.title = 'Volume: ' + porcento + '%';
                deslizante.value = String(porcento);
                deslizante.setAttribute('aria-valuetext', porcento + '%');
                deslizante.style.setProperty('--preenchido', porcento + '%');
                valorVolume.textContent = porcento + '%';

                botaoVelocidade.textContent = rotuloVelocidade(ajustes.velocidade);
                botaoVelocidade.setAttribute('aria-label',
                    'Velocidade da leitura: ' + rotuloVelocidade(ajustes.velocidade));
                botaoVelocidade.title = 'Velocidade da leitura';
                opcoes.forEach(function (opcao) {
                    var marcada = parseFloat(opcao.dataset.velocidade) === ajustes.velocidade;
                    opcao.setAttribute('aria-checked', marcada ? 'true' : 'false');
                    opcao.tabIndex = -1;
                });
            }
        };

        controle.atualizar();
        return controle;
    }

    // Fecha os painéis ao clicar fora
    document.addEventListener('click', function (e) {
        controles.forEach(function (c) {
            if (!c.caixa.contains(e.target)) c.fechar();
        });
    });

    // ---------- Encontrar os botões (inclusive os criados depois pelo JavaScript do quiz) ----------

    function aprimorar(raiz) {
        controles = controles.filter(function (c) { return document.body.contains(c.caixa); });
        var botoes = (raiz.querySelectorAll ? raiz : document).querySelectorAll('.botao-ouvir');
        Array.prototype.forEach.call(botoes, function (botao) {
            if (botao.__controleAudio || botao.hidden) return;
            botao.__controleAudio = true;
            controles.push(criarControle(botao));
        });
    }

    function iniciar() {
        aprimorar(document);
        new MutationObserver(function (mudancas) {
            var adicionou = mudancas.some(function (m) { return m.addedNodes.length > 0; });
            if (adicionou) aprimorar(document);
        }).observe(document.body, {childList: true, subtree: true});
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', iniciar);
    } else {
        iniciar();
    }
})();
