--- STEAMODDED HEADER
--- MOD_NAME: Diamond
--- MOD_ID: Diamond
--- MOD_AUTHOR: [tu_nombre]
--- MOD_DESCRIPTION: Mod de Isaac para Balatro
--- BADGE_COLOUR: 3FC7EB
--- PREFIX: diamond

----------------------------------------------
------------MOD CODE -------------------------

-- Registrar el atlas de Isaac
SMODS.Atlas {
    key = "isaac_atlas",
    path = "isaac.png",
    px = 71,
    py = 95
}

-- Registrar el atlas del D6
SMODS.Atlas {
    key = "d6_atlas",
    path = "dice_six.png",
    px = 71,
    py = 95
}

-- Crear el joker de Isaac
local isaac_joker = SMODS.Joker {
    key = "isaac",
    loc_txt = {
        name = "Isaac",
        text = {
            "{C:mult}+4{} Mult"
        }
    },
    config = {},
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    atlas = "isaac_atlas",
    pos = {x = 0, y = 0}
}

-- Definir el cálculo del joker
function isaac_joker:calculate(card, context)
    if context.joker_main then
        return {
            mult_mod = 4,
            message = localize('k_mult'),
            colour = G.C.MULT
        }
    end
end

-- Crear el joker D6
local d6_joker = SMODS.Joker {
    key = "d6",
    loc_txt = {
        name = "D6",
        text = {
            "Al {C:attention}venderse{}, reemplaza",
            "todos los {C:attention}Comodines{}",
            "por otros {C:green}aleatorios{}"
        }
    },
    config = {},
    rarity = 3, -- Raro
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false, -- No compatible con blueprint
    eternal_compat = true,
    atlas = "d6_atlas", -- Usando su propio atlas
    pos = {x = 0, y = 0} -- Posición en su atlas
}

-- Definir el cálculo del D6 - efecto al venderse
function d6_joker:calculate(card, context)
    -- Cuando se vende la carta
    if context.selling_card and context.card == card then
        -- Obtener todos los jokers actuales (excepto el D6 que se está vendiendo)
        local jokers_to_replace = {}
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] ~= card then
                table.insert(jokers_to_replace, G.jokers.cards[i])
            end
        end
        
        -- Solo ejecutar si hay jokers para reemplazar
        if #jokers_to_replace > 0 then
            -- Reemplazar cada joker por uno aleatorio
            for _, joker_card in ipairs(jokers_to_replace) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        -- Obtener un joker aleatorio
                        local eligible_jokers = {}
                        for k, v in pairs(G.P_CENTERS) do
                            if v.set == 'Joker' and v.discovered and not v.demo then
                                table.insert(eligible_jokers, k)
                            end
                        end
                        
                        if #eligible_jokers > 0 then
                            local random_joker = eligible_jokers[math.random(#eligible_jokers)]
                            
                            -- Crear la nueva carta
                            local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, random_joker)
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                            
                            -- Copiar edición y stickers si los tiene
                            if joker_card.edition then
                                new_card:set_edition(joker_card.edition)
                            end
                            if joker_card.ability.eternal then
                                new_card.ability.eternal = true
                            end
                            if joker_card.ability.perishable then
                                new_card.ability.perishable = joker_card.ability.perishable
                            end
                            
                            -- Remover el joker original
                            joker_card:start_dissolve()
                            
                            -- Efecto visual
                            new_card:juice_up(0.3, 0.5)
                            play_sound('timpani')
                        end
                        return true
                    end
                }))
            end
            
            -- Mensaje de confirmación
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "¡Rerolleado!",
                colour = G.C.MULT
            })
        end
    end
end

-- Función para agregar el D6 al inicio
local function add_starting_d6()
    -- Verificar si se seleccionó la baraja de Isaac
    if G.GAME.selected_back and G.GAME.selected_back.name == 'b_diamond_isaac_deck' then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                local d6_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_diamond_d6')
                d6_card:add_to_deck()
                G.jokers:emplace(d6_card)
                d6_card:start_materialize()
                return true
            end
        }))
    end
end

-- Función para agregar el Samson al inicio
local function add_starting_samson()
    if G.GAME.selected_back and G.GAME.selected_back.name == 'b_diamond_samson_deck' then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                local samson_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_diamond_samson')
                samson_card:add_to_deck()
                
                -- Hacer el joker Eterno
                samson_card.ability.eternal = true
                
                -- Hacer el joker Negativo
                samson_card:set_edition({negative = true})
                
                G.jokers:emplace(samson_card)
                samson_card:start_materialize()
                return true
            end
        }))
    end
end

-- Función para agregar el efecto de cristal al inicio
local function add_cristal_effect()
    if G.GAME.selected_back and G.GAME.selected_back.name == 'b_diamond_cristal_deck' then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                -- Convertir todas las cartas del mazo a cristal
                for i = 1, #G.deck.cards do
                    local card = G.deck.cards[i]
                    if card then
                        -- Aplicar el enhancement de cristal
                        card:set_ability(G.P_CENTERS.m_glass, nil, true)
                        card:juice_up(0.3, 0.5)
                    end
                end
                  -- Mensaje de confirmación
                if #G.deck.cards > 0 then
                    card_eval_status_text(G.deck.cards[1], 'extra', nil, nil, nil, {
                        message = "¡Todo es cristal!",
                        colour = G.C.BLUE
                    })
                    play_sound('generic1')
                end
                
                return true
            end
        }))
    end
end

-- Función para agregar el efecto de roca al inicio
local function add_roca_effect()
    if G.GAME.selected_back and G.GAME.selected_back.name == 'b_diamond_roca_deck' then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                -- Convertir todas las cartas del mazo a piedra
                for i = 1, #G.deck.cards do
                    local card = G.deck.cards[i]
                    if card then
                        -- Aplicar el enhancement de piedra
                        card:set_ability(G.P_CENTERS.m_stone, nil, true)
                        card:juice_up(0.3, 0.5)
                    end
                end
                
                -- Mensaje de confirmación
                if #G.deck.cards > 0 then
                    card_eval_status_text(G.deck.cards[1], 'extra', nil, nil, nil, {
                        message = "¡Todo es roca!",
                        colour = G.C.ORANGE
                    })
                    play_sound('generic1')
                end
                
                return true
            end        }))
    end
end

-- Función para agregar jokers aleatorios al inicio (Eden)
local function add_eden_random_jokers()
    if G.GAME.selected_back and G.GAME.selected_back.name == 'b_diamond_eden_deck' then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                -- Crear 3 jokers aleatorios
                for i = 1, 3 do
                    -- Obtener una lista de jokers disponibles
                    local joker_list = {}
                    for k, v in pairs(G.P_CENTERS) do
                        if v.set == 'Joker' and v.discovered and not v.demo and k ~= 'j_joker' then
                            table.insert(joker_list, k)
                        end
                    end
                    
                    if #joker_list > 0 then
                        local random_joker_key = joker_list[math.random(#joker_list)]
                        
                        -- Crear el joker
                        local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, random_joker_key)
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        
                        -- Darle una edición aleatoria ocasionalmente
                        if math.random() < 0.15 then -- 15% de probabilidad
                            local editions = {
                                {foil = true},
                                {holo = true},
                                {polychrome = true}
                            }
                            local random_edition = editions[math.random(#editions)]
                            new_joker:set_edition(random_edition)
                        end
                        
                        -- Hacer el joker eterno ocasionalmente
                        if math.random() < 0.1 then -- 10% de probabilidad
                            new_joker.ability.eternal = true
                        end
                        
                        new_joker:start_materialize()
                        new_joker:juice_up(0.3, 0.5)
                        delay(0.2)
                    end
                end
                
                -- Mensaje de confirmación
                if #G.jokers.cards > 0 then
                    card_eval_status_text(G.jokers.cards[1], 'extra', nil, nil, nil, {
                        message = "¡Eden recibe jokers aleatorios!",
                        colour = G.C.GREEN
                    })
                    play_sound('generic1')
                end
                
                return true
            end
        }))
    end
end

-- Función para hacer la tienda gratis para The Lost
local function make_shop_free_for_lost()
    if G.GAME and G.GAME.lost_deck_active and G.shop and G.shop.cards then
        -- Hacer que todas las cartas de la tienda cuesten 0
        for k, card in pairs(G.shop.cards) do
            if card and card.cost then
                card.cost = 0
            end
        end
        
        -- Hacer que los boosters cuesten 0
        if G.shop_booster and G.shop_booster.cards then
            for k, card in pairs(G.shop_booster.cards) do
                if card and card.cost then
                    card.cost = 0
                end
            end
        end
        
        -- Hacer que los vouchers cuesten 0
        if G.shop_vouchers and G.shop_vouchers.cards then
            for k, card in pairs(G.shop_vouchers.cards) do
                if card and card.cost then
                    card.cost = 0
                end
            end
        end
    end
end

-- Variables para los hooks
local original_buy_from_shop = nil
local original_reroll_shop = nil
local original_ease_dollars = nil
local original_use_card = nil

-- Función para inicializar los hooks una vez que el juego esté cargado
local function initialize_lost_hooks()
    if not original_buy_from_shop and G and G.FUNCS and G.FUNCS.buy_from_shop then
        original_buy_from_shop = G.FUNCS.buy_from_shop
        G.FUNCS.buy_from_shop = function(e)
            -- Si es The Lost, forzar dinero gratis para todo excepto rerolls
            if G and G.GAME and G.GAME.lost_deck_active and G.STATE == G.STATES.SHOP then
                local card = e.config.ref_table
                if card and card.cost then
                    print("The Lost: Buy from shop - Cost: $" .. card.cost)
                    -- Temporalmente poner el costo a 0
                    local original_cost = card.cost
                    card.cost = 0
                    
                    local result = original_buy_from_shop(e)
                    
                    -- Restaurar el costo para la UI (pero ya se compró gratis)
                    card.cost = original_cost
                    print("The Lost: Purchase completed for free!")
                    
                    return result
                end
            end
            return original_buy_from_shop(e)
        end
    end
    
    if not original_reroll_shop and G and G.FUNCS and G.FUNCS.reroll_shop then
        original_reroll_shop = G.FUNCS.reroll_shop
        G.FUNCS.reroll_shop = function(e)
            print("The Lost: Reroll shop (should cost money)")
            -- Los rerolls siempre funcionan normalmente
            return original_reroll_shop(e)
        end
    end
    
    -- Interceptar también use_card para boosters
    if not original_use_card and G and G.FUNCS and G.FUNCS.use_card then
        original_use_card = G.FUNCS.use_card
        G.FUNCS.use_card = function(e)
            -- Si es The Lost y estamos en la tienda
            if G and G.GAME and G.GAME.lost_deck_active and G.STATE == G.STATES.SHOP then
                local card = e.config.ref_table
                if card and card.cost and card.cost > 0 then
                    print("The Lost: Use card - Setting cost from $" .. card.cost .. " to $0")
                    -- Temporalmente poner el costo a 0
                    local original_cost = card.cost
                    card.cost = 0
                    
                    local result = original_use_card(e)
                    
                    -- Restaurar el costo para la UI
                    card.cost = original_cost
                    print("The Lost: Card used for free!")
                    
                    return result
                end
            end
            return original_use_card(e)
        end
    end
    
    if not original_ease_dollars and ease_dollars then
        original_ease_dollars = ease_dollars
        ease_dollars = function(mod, instant)
            -- Si es The Lost y estamos gastando dinero (mod negativo)
            if G and G.GAME and G.GAME.lost_deck_active and mod < 0 and G.STATE == G.STATES.SHOP then
                -- Solo permitir gastos si es específicamente un reroll
                local current_reroll_cost = G.GAME.current_round and G.GAME.current_round.reroll_cost or 5
                local is_reroll = math.abs(mod) == current_reroll_cost
                
                -- Si no es un reroll, bloquear el gasto completamente
                if not is_reroll then
                    print("The Lost: BLOCKED money spend of $" .. math.abs(mod))
                    return -- No gastar dinero en compras de tienda
                else
                    print("The Lost: ALLOWED reroll cost of $" .. math.abs(mod))
                end
            end
            return original_ease_dollars(mod, instant)
        end
    end
end

-- Función para aplicar el efecto de The Lost
local function apply_lost_effect()
    if G.GAME.selected_back and G.GAME.selected_back.name == 'b_diamond_lost_deck' then
        -- Reducir las manos a 1
        G.GAME.round_resets.hands = 1
        G.GAME.current_round.hands_left = 1
        
        -- Marcar que esta partida tiene el efecto de The Lost
        G.GAME.lost_deck_active = true
        
        -- Debug: Verificar que se está aplicando
        print("The Lost deck activated!")
        
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                -- Mensaje de confirmación
                card_eval_status_text(G.deck.cards[1] or {T = {x = 0, y = 0}}, 'extra', nil, nil, nil, {
                    message = "¡The Lost: 1 mano, tienda gratis!",
                    colour = G.C.DARK_EDITION
                })
                play_sound('generic1')
                return true
            end
        }))
    end
end

-- Función para hacer la tienda gratis cuando se entra a la tienda
local function make_shop_free_if_lost()
    if G.GAME and G.GAME.lost_deck_active then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                make_shop_free_for_lost()
                return true
            end
        }))
    end
end

-- Event listener para el inicio de la partida
local game_start_run_ref = Game.start_run
function Game:start_run(args)
    -- Inicializar los hooks de The Lost cuando el juego esté completamente cargado
    initialize_lost_hooks()
    
    local ret = game_start_run_ref(self, args)
    add_starting_d6()
    add_starting_samson()
    add_eden_random_jokers()
    apply_lost_effect()
    add_cristal_effect()
    add_roca_effect()
    return ret
end

-- Función para mantener las manos a 1 en cada ronda (The Lost)
local update_round_ref = Game.update_round
function Game:update_round(dt)
    if G.GAME and G.GAME.lost_deck_active then
        -- Mantener las manos siempre en 1
        if G.GAME.current_round and G.GAME.current_round.hands_left and G.GAME.current_round.hands_left > 1 then
            G.GAME.current_round.hands_left = 1
        end
        if G.GAME.round_resets and G.GAME.round_resets.hands and G.GAME.round_resets.hands > 1 then
            G.GAME.round_resets.hands = 1
        end
    end
    return update_round_ref(self, dt)
end

-- Interceptar el costo de cartas en la tienda para The Lost
local card_get_cost_ref = Card.get_cost
function Card:get_cost()
    return card_get_cost_ref(self)
end

-- Crear la baraja de Isaac (sin función apply_to_run)
local isaac_deck = SMODS.Back {
    key = "isaac_deck",
    loc_txt = {
        name = "Baraja de Isaac",
        text = {
            "Empiezas con un {C:attention}D6{}",
            "en tu inventario"
        }
    },
    atlas = "isaac_atlas",
    pos = {x = 0, y = 0},
    config = {}
}

-- Crear el joker de Samson
local samson_joker = SMODS.Joker {
    key = "samson",
    loc_txt = {
        name = "Samson",
        text = {
            "{C:red}X0.75{} Mult, gana {C:red}+X0.25{} Mult",
            "por cada {C:attention}Ciega{} ganada",
            "{C:inactive}(Actualmente: {C:red}X#1#{C:inactive}){}"
        }
    },
    config = {
        extra = {
            base_mult = 0.75,
            increment = 0.25,
            current_mult = 0.75
        }
    },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false, -- No compatible con blueprint
    eternal_compat = true,
    atlas = "samson_atlas",
    pos = {x = 0, y = 0}
}

-- Definir el cálculo del joker de Samson
function samson_joker:calculate(card, context)
    -- Actualizar el multiplicador actual basado en las ciegas ganadas
    local blinds_won = math.max(0, G.GAME.round_resets.ante - 1)
    local old_mult = card.ability.extra.current_mult
    local new_mult = card.ability.extra.base_mult + (blinds_won * card.ability.extra.increment)
    
    if context.joker_main then
        card.ability.extra.current_mult = new_mult
        return {
            Xmult_mod = card.ability.extra.current_mult,
            message = localize('k_mult'),
            colour = G.C.MULT
        }
    end
    
    -- Detectar cuando aumenta la rabia al ganar una ciega
    if context.end_of_round and not context.individual and not context.repetition then
        local future_mult = card.ability.extra.base_mult + (G.GAME.round_resets.ante * card.ability.extra.increment)
        if future_mult > card.ability.extra.current_mult then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function()
                    -- Animación de rabia creciente
                    card:juice_up(0.8, 0.8)
                    
                    -- Sonido de rabia
                    play_sound('tarot1', 1.2, 0.7)
                    
                    -- Mensaje de rabia aumentada
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "¡AUMENTA LA RABIA DE SAMSON!",
                        colour = G.C.RED
                    })
                    
                    -- Actualizar el multiplicador
                    card.ability.extra.current_mult = future_mult
                    
                    return true
                end
            }))
        end
    end
end

-- Función para mostrar variables localizadas del joker
function samson_joker:loc_vars(info_queue, card)
    return {vars = {card.ability.extra.current_mult}}
end

-- Registrar el atlas de Samson
SMODS.Atlas {
    key = "samson_atlas",
    path = "samson.png",
    px = 71,
    py = 95
}

-- Registrar el atlas de Eden
SMODS.Atlas {
    key = "eden_atlas",
    path = "eden.png",
    px = 71,
    py = 95
}

-- Registrar el atlas de The Lost
SMODS.Atlas {
    key = "lost_atlas",
    path = "lost.png",
    px = 71,
    py = 95
}

-- Crear la baraja de Samson (ahora solo da el joker)
local samson_deck = SMODS.Back {
    key = "samson_deck",
    loc_txt = {
        name = "Baraja de Samson",
        text = {
            "Empiezas con un {C:attention}Samson{}",
            "{C:dark_edition}Negativo{} y {C:red}Eterno{}"
        }
    },
    config = {},
    unlocked = true,
    discovered = true,
    atlas = "samson_atlas",
    pos = {x = 0, y = 0}
}

-- Crear la baraja de Eden
local eden_deck = SMODS.Back {
    key = "eden_deck",
    loc_txt = {
        name = "Baraja de Eden",
        text = {
            "Empiezas con {C:attention}3{} jokers",
            "{C:green}completamente aleatorios{}"
        }
    },
    config = {},
    unlocked = true,
    discovered = true,
    atlas = "eden_atlas",
    pos = {x = 0, y = 0}
}

-- Crear la baraja de The Lost
local lost_deck = SMODS.Back {
    key = "lost_deck",
    loc_txt = {
        name = "Baraja de The Lost",
        text = {
            "Solo tienes {C:attention}1 mano{} por ronda",
            "Toda la {C:attention}tienda{} es {C:green}gratis{}",
            "{C:inactive}(excepto rerolls)"
        }
    },
    config = {},
    unlocked = true,
    discovered = true,
    atlas = "lost_atlas",
    pos = {x = 0, y = 0}
}



-- Registrar el atlas de Cristal
SMODS.Atlas {
    key = "cristal_atlas",
    path = "cristal.png",
    px = 71,
    py = 95
}

-- Crear la baraja de Cristal
local cristal_deck = SMODS.Back {
    key = "cristal_deck",
    loc_txt = {
        name = "Baraja de Cristal",
        text = {
            "Todas las cartas son",
            "{C:attention}Cartas de Cristal{}"
        }
    },
    config = {},
    unlocked = true,
    discovered = true,
    atlas = "cristal_atlas",
    pos = {x = 0, y = 0}
}

-- Registrar el atlas de Roca
SMODS.Atlas {
    key = "roca_atlas",
    path = "roca.png",
    px = 71,
    py = 95
}

-- Crear la baraja de Roca
local roca_deck = SMODS.Back {
    key = "roca_deck",
    loc_txt = {
        name = "Baraja de Roca",
        text = {
            "Todas las cartas son",
            "{C:attention}Cartas de Piedra{}"
        }
    },
    config = {},
    unlocked = true,
    discovered = true,
    atlas = "roca_atlas",
    pos = {x = 0, y = 0}
}

----------------------------------------------
------------MOD CODE END----------------------