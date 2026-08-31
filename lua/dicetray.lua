local TableUtils = require("lua.utils-table")
local EventUtils = require("lua.utils-events")
local UiUtil = require("lua.utils-ui")
local Utils = require("lua.utils")


local rotValues3d_d6 = {{
    value = 1,
    rotation = {
        x = 0,
        y = 0,
        z = -180
    }
}, {
    value = 2,
    rotation = {
        x = 0,
        y = 0,
        z = 90
    }
}, {
    value = 3,
    rotation = {
        x = -90,
        y = 0,
        z = 0
    }
}, {
    value = 4,
    rotation = {
        x = 90,
        y = 180,
        z = 0
    }
}, {
    value = 5,
    rotation = {
        x = 0,
        y = 0,
        z = -90
    }
}, {
    value = 6,
    rotation = {
        x = 0,
        y = 180,
        z = 0
    }
}}

local TEXTURES
TEXTURES = {
    -- ["Father Christmas"] = {
    --     category = "House",
    --     dice = "http://cloud-3.steamusercontent.com/ugc/1647720232364319121/CD2770AD1B43374E5CAE14FCAC86EBF89A681E49/"
    -- },
    -- ["Easter Bunny"] = {
    --     category = "House",
    --     dice = "http://cloud-3.steamusercontent.com/ugc/1714157486104222812/452C57EF76531411978B0C17618EB62D0669C6F9/"
    -- },
    ["Baratheon"] = {
        category = "House",
        dice = "http://cloud-3.steamusercontent.com/ugc/1461933821421515299/0A2555822CDDB1BC3EA84AB1E16BD528FD82A8B7/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066784704/ED8D0B3139C241C437355C095E18B3FB84E736BB/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1710786701663891243/B24728320E96F1F22374E6EC7D1A1E77F5EA6825/",
    },
    ["Brotherhood"] = {
        category = "House",
        dice = "https://steamusercontent-a.akamaihd.net/ugc/46833816919571813/C7933C4A9976C0BBCD6876A84A08987CE22C657A/",
        panic = "https://steamusercontent-a.akamaihd.net/ugc/46833816919571901/2FA9F10EA885042E0C40469807244782A01C7535/",
        decal = "https://steamusercontent-a.akamaihd.net/ugc/46833816919583803/5D9072EB4486DB10A85A5D5872E6196D1A60FCF5/",
        scale = 6
    },
    ["Bolton"] = {
        category = "House",
        dice = "https://steamusercontent-a.akamaihd.net/ugc/46819323404322418/6DF70484F70FDA43959D76279E88C910FB1FDDCB/",
        panic = "https://steamusercontent-a.akamaihd.net/ugc/46819323404322476/C7EE3E06FFDB744A408B5BEF3D4C69E38B8A6337/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1710786701663890405/7B9980E3D95272257CC81EC7541EE980EB4B11D0/",
    },
    ["Free Folk"] = {
        category = "House",
        dice = "http://cloud-3.steamusercontent.com/ugc/1461933821421505221/8B23C70F43F565DE3CB338469183DB1728C7BCAF/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066784527/035EFDC29B492A3F40A5421F9CD993EF2F8B4848/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1710786701663891349/F346960EB50BCA4CCD780FA8B007BA634FC2D3F9/",
    },
    ["Greyjoy"] = {
        category = "House",
        dice = "http://cloud-3.steamusercontent.com/ugc/1646593864309530277/298F08FD72F680AE787991E14D29624CEE7215FA/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066784444/C90AE6A97CD5811BF7A927F224DB1F073D688719/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1710786701663891075/5E9BD07318515D6B9CD021E722E8A7DC8CA4C342/",
    },
    ["Lannister"] = {
        category = "House",
        dice = "http://cloud-3.steamusercontent.com/ugc/1461933821421519475/9FFBF8B31045E38FB29BF1CDD420263E9CC92A88/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066784367/D56B37D6BE4B31D4EF8DE901FE795438578A1389/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1710786701663890737/1A8C5DDEC221FDE1CA132ABCEE93BBA264A0428A/",
    },
    ["Martell"] = {
        category = "House",
        dice = "http://cloud-3.steamusercontent.com/ugc/1937136685238793000/669D12E0D4607269C119E5545873FC2F9A591A0D/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066784290/1241EC88C10875EBB3DA8A0D960F075F4EEB42A5/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1937136685238793848/43CDF7B66FE50D462D18CE8BC1FA3A49BB665601/",
    },
    ["Neutral"] = {
        category = "House",
        dice = "http://cloud-3.steamusercontent.com/ugc/1461933821421512830/BC6B56FCF24BBCCCAFF63104EC334D53C6C48D84/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066784194/4FCCBD5136D6DA7F87786C2F399DD5498ED602CB/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1710786701663890405/7B9980E3D95272257CC81EC7541EE980EB4B11D0/",
    },
    ["Night's Watch"] = {
        category = "House",
        dice = "http://cloud-3.steamusercontent.com/ugc/1461933821421508311/5C7416D22B4AFF268C50B23E905A6434768B228B/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066784097/741AE2B394B324CD362FC02D2EFE618F615EA594/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1710786701663891430/65AB9005736394B97C2EEE3E22B1BF2FC34F799F/",
    },
    ["Stark"] = {
        category = "House",
        dice = "http://cloud-3.steamusercontent.com/ugc/1461933821421500657/3EE68D70440A5D5515AE8C92607E539F82F8BA8E/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066783998/50A5DBC4A4FAF217F8AA65B75AD2117665170EF1/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1710786701663890587/EF6295A65C9B50096DF4123B3B7DFC4691BEC49F/",
    },
    ["Targaryen"] = {
        category = "House",
        dice = "http://cloud-3.steamusercontent.com/ugc/1001431356119582534/97C130D32985DC001AC4A85DFC98C79EACF4D575/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066783911/08864D2E400CAB464E40A5F12A9C5DDD8EBB0D63/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1710786701663890868/CBCC3892E00A33583276D410A7E26FFE53825242/",
    },

    ["1st Draft Commemoration"] = {
        category = "Community",
        dice = function()
            local dice_house = TableUtils.filter(TEXTURES, function(t) return t.category == "House" end)
            local ix = math.random(1, #dice_house)
            return dice_house[ix].dice
        end,
        panic = function()
            local dice_house = TableUtils.filter(TEXTURES, function(t) return t.category == "House" end)
            local ix = math.random(1, #dice_house)
            return dice_house[ix].panic
        end,
        decal = "https://steamusercontent-a.akamaihd.net/ugc/2481009755930507726/1ACE9BF63B47980A68A5BC60B32F4CC19C3009D9/",
        scale = 10,
    },

    ["ASoIaF Guild"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608606395/6B24A134FC33E539C4E8130E30D6A61294CDAB2E/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949709274/8DD635C1F04E58462D1BB1B2B15795271A5D25F2/",
        scale = 10
    },
    ["Online Circuit"] = {
        category = "Community",
        dice = "https://steamusercontent-a.akamaihd.net/ugc/46827574652623871/209A19CC0CB4547C7436374E8F9468234B00D127/",
        panic = "https://steamusercontent-a.akamaihd.net/ugc/46827574652623945/E8393D7C383489EEF45F3F6CF4BBFC6F7412D071/",
        decal = "https://steamusercontent-a.akamaihd.net/ugc/2481009755930507726/1ACE9BF63B47980A68A5BC60B32F4CC19C3009D9/",
        scale = 10,
    },
    ["ASoIaF Stats"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608606836/65D5EF956EA74D4D2CAD543728ED2AAF54C1FC0F/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066770018/E279FA4B95DEBB01645C042B08E47C7A9F09D4CE/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949570979/78406F7C7DCEFA4B34ADE987A2D719B076E581E3/",
    },
    ["Bartender"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1753559404952174110/124E3FD177B44F8EA6367BD92F783AC45F6D5878/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066769106/31CEF2EE0EEC80949C47690388AD17E1C99ADECC/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404952271725/EC9A595863ACBEAD00479473F80C04D82BB2DD5B/",
        scale = 6
    },
    ["Blitzminis"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608607491/BF00589456BA22F9A792F922913A9F5A37872B3D/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066769685/070DBCF6BE00679AE1B2F1D3E394E9DBFE710609/"
    },
    ["CMON"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608645171/2551BEED657057E9423E69A1698ADEC957E2C944/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066769460/AD4D01368BFADAF1588BAFF37C3CCB3229C822B0/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949571700/D6C421BB13C2693FF44C198F4882DB5E744B6E33/",
        scale = 10
    },
    ["Mythicos Studio"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608614371/64BB607EBDC12CA19178C31F3AEBBC6DF1E2963B/"
    },
    ["NRG"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608615074/14CC88B323280462E5773B7126C64A566C133EF1/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066768923/5EBEECF6DFFB34ABA1F5DBBE33F3CB4A9BE360A2/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949572476/45680A61638397C537DAF02B19F98CFE0DA48596/",
        scale = 10
    },
    ["OTTG"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608617997/FED7BC1E1A1992D29AA27AFBD3BA6935CD327DE9/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066768817/7036993B7B839678D3C51503C97AB75DC45D72BD/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949780711/C423F4FC6483D3B8665CD6EE331C811799F368F1/",
        scale = 10
    },
    ["RC - Golden Company"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1929247284420178959/62B2738151C806870B38950C89A26A7FF43309FC/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1929247284420202711/8F77B10D9EF900C487F17C4D523F027794C8CD2E/",
        scale = 7
    },
    ["White Scars"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1714157571899756654/C2DFA42C409F540292C30A35EBA8FE8F7BCA2AC6/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066770200/34DDC3D9378DB38C690D6B412CC559A7AB68623D/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1738925945683367223/1487C5AE25260A41C440F776132F27CF6066A244/",
    },
    ["Small Council Radio"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608620117/A16ADC1E92266181455F9EFA7A1EDF27323F8EA8/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066768612/07690107543F4CDAF825E7A7803937282934A8A3/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949574846/36E4AAED8216528D9458028EDF9746E3D8C4D130/",
    },
    ["Sunday Slaughter"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1747940860543269126/F374ADEF6214AC4ACC85518D0F17952022AE998C/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066768482/62619BADA54F9B32CD86F40CF802E242E5A6010B/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949774389/F1F39E4E9F9BAA25CA76D92BC7DFB7891EF822FF/",
        scale = 7
    },
    ["Tabletop Warden"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608621129/7BCAA37618E8116BC12004639CB74750DD445C9A/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2523781903915372259/E4F8BBE2BECF88B1BCE8AE91084E6524C58436DD/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949577896/3C111159C242A863D21A116F8CB4A2C19221DA3E/",
        scale = 7
    },
    ["Anything But 1"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1753559404949741621/51A3B17FBF785ED6F667A98559D268B56FB1D545/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066769804/3D4D0B7614E2A6A6C7EC14D74E5DB09EB357E30C/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949570296/6137B0D81567CD445AAE5CE11952D26159D833D8/",
        scale = 7
    },
    ["Wargames Indonesia"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1753559404949740509/2912FA09D7DE01DE18BE13E471CDCBDC524150EC/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066769899/AC63B8D58121E5C72F0C1FAAB1D7745CA244B0A5/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949579379/A22023416FAE2F6F1B1043BD13C3F57F74690602/",
        scale = 7
    },
    ["Rainbow"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/1688269185288178177/5182B0E3C9B1599788516B8A207EF56CAD880034/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066768705/DFC5B5691F4A8A7806AA9FCF6FBA6D186FC49A2E/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1688269185288176215/4CDBB5D1E395CC6F39EDFD17829349457601CAC5/",
        scale = 7
    },
    ["Hits And Crits"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/2313225941491939830/5CB21B11C66D8D6CBB9F1E0C1C14637945DF79A0/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2475368207906658992/CC3D6373A99B3ECF71F745B4EE265E06CF8B5CD2/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2319980405508522300/A557FA90B1EAD97F01C39539B971C965F8C5A3C6/",
        scale = 7
    },
    ["Drunken Dwarfs"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/2318855441020769520/138E15A2C48B2F94246527A58AE9A36C6D33A6CE/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066769304/92117DC01F92BD9AB1D171EE6A72ED6C999C830D/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2318855441020767411/DE6DAE318CA005D4CAFDA3E8F3BC1CE02D75AD64/",
        scale = 7
    },
    ["Colombian Hippos"] = {
        category = "Community",
        dice = "http://cloud-3.steamusercontent.com/ugc/2458483061635061298/5903EF6E4D6A737CB998AFBF77C1F51728EED2C0/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2458483061635061432/1D8673F97064CA0766CECB8CF61F5683D6042D99/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2458483061635065786/DF951184EE19820B48D72C87667BA95679594036/",
    },
    ["Lords of the North"] = {
        category = "Community",
        dice = "https://steamusercontent-a.akamaihd.net/ugc/2429222166862080482/0D3BE22B5AD94E56C58795A59493678367A8D3AA/",
        panic = "https://steamusercontent-a.akamaihd.net/ugc/2429222166862080549/DD798AEB5090D114888BC76A73C68804B1C1B626/",
        decal = "https://steamusercontent-a.akamaihd.net/ugc/2429222166862076621/A22106B342550160D6B4EC6F8D2ACA10784836F7/",
    },
    ["Crab Smugglers"] = {
        category = "Community",
        dice = "https://steamusercontent-a.akamaihd.net/ugc/10501663033986947599/41FEDDBD88F82E00312294EDA1C902C1972C5884/",
        decal = "https://steamusercontent-a.akamaihd.net/ugc/12645753997011993099/E9AD26EDFC73F032AD5484F0BE59064912B3191E/",
    },

    ["Fantasy League"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608609462/6F5AB8E570B66EF88A9177A518B9253BF851F4CF/"
    },
    ["Team Super League"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608621556/E81D56363803C4D788E6CC1330CB40ED539C6BF8/"
    },
    ["B For Better"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608607148/0BD51F6C046FF70AB29B1ED06AF27B2BAEF81460/"
    },
    ["Bremen Highlanders"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608607866/3BD83262A8A4B843DC914F53DDA00A94184C94E1/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066769575/EC6B0D2C5D5C2D9E8344818FA61A8B738B97841E/"
    },
    ["B’hrollor Faithful"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608622117/B5839324EF540C40EBBADA345CABC9CB34E4DF9E/"
    },
    ["Brawlers"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608615654/B05D151A3AACD757B16B161ECBBA7749F1F4B2A9/"
    },
    ["Brotherhood without Banners"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608608266/70EB89D729A3AD4F88AC323B8E5A50480C6A48DB/"
    },
    ["Buddy Gang"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608678263/5BA6B25609FA15B3D584DC7C10D4232CEC0DCDD4/"
    },
    ["Easterosi Waterdancers"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608609074/8442D42F437022F1D3ECF1B7A52CBF2F9726DE94/"
    },
    ["Faceless Men"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1710786701663093484/4C6BB10C99A759429C319A22DFF1BF83B53F9777/"
    },
    ["Fellowship"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1747940860535895337/FED15B3420CD2FF8EF78CDB3BDFDA8262D89EFF2/"
    },
    ["Go Big or Go Home"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608609895/7F30B3528D0B43EB3625EC64121F500C15E7B8A3/"
    },
    ["GoT Bois?"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608611083/CD0CE1C598DF2D1852C8AECA703BB61651CD654B/"
    },
    ["Kingsguard"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1747940860535895190/2AAEEE434179E4046C54B3D5C2AA6185D7F4DCF4/"
    },
    ["Knights of Summer"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608613549/BA89C98130002FF63A49B34AA35975569153A09D/"
    },
    ["Lightning Lords"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608613943/97C0B5004BFA7B39E9A376D975A9FD53A894C5E9/"
    },
    ["Onion Smugglers"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608611608/A2579C27A0837FA08312CDABADBC9A80B64CF912/"
    },
    ["Poof Gaming"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608618632/F5B93CD6CEC6EC32FBEEE23C137C954B2C42797F/"
    },
    ["Rightful Heirs"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608619673/ADE830CFF472C4295CC0A6C680FCEF75D98BC2DC/"
    },
    ["Roosters"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608622943/6509BFDD3A1A517F05C965344F8ADF5561A82ACF/"
    },
    ["Smaller Council"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608622519/929BE54207BC610DE9AD895E93B9D7E38E8CA9B6/"
    },
    ["Steadfast ORJ"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608617245/7EFBF9737CC1D0409946FD526EE296B2D4D71A37/"
    },
    ["The First Men"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1747940860535895024/6747EF9C21A2DD431625B3CC24E2F85EA0E81ED7/"
    },
    ["The Welsh Drogons"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1747940860535952423/93097336C0945F7A4CA5779A208AA658CD34BD6B/"
    },
    ["Three Sails"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201530628754739/6463CEBBE63F2F4029E3648480A55FE02586B63D/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066768297/945636A0DFE44EAA631C21592F95781067D5F29C/",
        decal = "http://cloud-3.steamusercontent.com/ugc/1753559404949773365/0CF74FAB059134087F8D88711ADFC4F062606B55/",
        scale = 7
    },
    ["Westcoast Bannermen"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608623406/380D21030C83C86B78809F8F5E4F4D12CF6966C0/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066770108/9CD38707AA1120E13988D027215261317905E619/"
    },
    ["Western Warriors"] = {
        category = "TSL",
        dice = "http://cloud-3.steamusercontent.com/ugc/1482201921608623792/41E7EF043D9CB84C3B585B3AA7983F8A2D6AEDF9/"
    },

    ["World Cup"] = {
        category = "World Cup",
        sort = -100,
        dice = "http://cloud-3.steamusercontent.com/ugc/2077890188695675088/897501E13E36B13DE0BE4695EFB79CA574BE4414/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066779311/FE03826DAEDC89A3A2C3E7C488AF023D7C3AB239/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2077890188695673283/1FD083710E5C787503AABAFFDF68ECC5720BA648/",
    },
    ["Spain"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2072259893572234769/76E91578369AA392A169E3489BA90A014E0C7E40/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066781350/EFD452810789FAB5A847A00FB661BCCFA20B3D7C/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2072260689156763399/79BA031A95C1A134292532E0C1BB2E3CA1CCF123/",
        scale = 4
    },
    ["Canada"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2478742831195282283/BD4EB845F459AED775D71574B508717AA2C087BE/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066782177/0651BA7B3CAA8D7B4FEFEF8E9EB5F34FA075DECC/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2478742831195294486/94A9E12B1168C98BB296EAD0EDAAB7E3CE4524E2/",
    },
    ["Germany"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2072260689154210586/3CD42E2BF2DB914C7833D0B1B2EAD1FB8032E77C/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066781886/0293ABD262D95DA28DAD6ABD8B417871887DFDDF/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2072260689154215453/4809C10D024A35C6ED75FE3915C06F9DB722DB8C/",
    },
    ["Indonesia"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2478742831195280448/3F1E0D800B3E3C0F3B2E394F166850A582DB17B7/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066781652/F0CEA97926CE54DE9029F68D7C2B7BFA769B15F5/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2478742831195220555/C70C67FAEEBD5D57075C33F47E35D2D607A79BF1/",
    },
    ["USA"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2072260689154210818/8DE8B824554EE4B6BDBB357B8C126A9B3FA40976/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066781244/900285F10466ACDE9D6875CE18150A31DD972208/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2072260689156763637/F79617BFBE3D0EA8E22BAC7F488EA166B2FB94E2/",
        scale = 7
    },
    ["United Nations"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2072260689154210671/AAF1D56AC2715D04B33801114A377E2780994E5C/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2072260689156763498/385A3639C101B165EFAA95339CB836150384864C/",
    },
    ["France"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2072260689156654565/5EACF3BC4D13802C3CA2EC3333DD5F56BF413294/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066781982/9890A21285ECC7AA7968144400BEB879D0F71DE9/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2077890188694804959/6174C77F548E7015CAEDAD08CAD263789AF2B5D7/",
    },
    ["England"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2072260689156654470/95F441BB5D5C1CE33E088D1D6FBD83EEC314CD69/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066782072/0527AECB262BD348AF4B6A225694F2D2A35273E1/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2077890188694804824/B655A6326130D87589454D15B1D0064F6B248175/",
    },
    ["Hungary"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2073387153005089955/1FF1CF9BA5B73F77570322E36F3096E1D4F509D6/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066781777/55CFCB31D270D3E8AB60DAD9BB040A4DCDB5A388/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2073387153005096205/4258A33655EFCCCF5D4EC1ECC5738D31CBE7990C/",
    },
    ["Poland"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2072260689156654835/A03492AB8EA3A8452D256E6DF10484AAA1B4F60F/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066781530/78076B01F51710E5D4E327B98AF77E322F54B086/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2077890188695582585/1536EFB504FC071BAE1F3D980288BE937084E183/",
    },
    ["Wales"] = {
        category = "World Cup",
        dice = "http://cloud-3.steamusercontent.com/ugc/2072260689156654948/BB1BF6C8E608DC482CEDFA5CC2D305D6C7CCD3F7/",
        panic = "http://cloud-3.steamusercontent.com/ugc/2502390525066781056/C5C3FF904561F318668BDCAFA94C4FD75E1379C9/",
        decal = "http://cloud-3.steamusercontent.com/ugc/2077890188694805284/C803F4A322B856AC1D0E1E460AE966A9DE2CD5A2/",
    },
    ["Finland"] = {
        category = "World Cup",
        dice = "https://steamusercontent-a.akamaihd.net/ugc/14245950535894975088/B5EC492561E5EB5862D1FDC90EE1F53DB3CBA4FC/",
        panic = "https://steamusercontent-a.akamaihd.net/ugc/16561304082206471158/0C11EF0D6DC427BEC99FDC5A4F0C153046C7228D/",
        decal = "https://steamusercontent-a.akamaihd.net/ugc/16018207439739906876/A47B8F9334B221FAB02E519E172874A4DA8E4670/",
        scale = 7,
    },
    ["Ukraine"] = {
        category = "World Cup",
        dice = "https://steamusercontent-a.akamaihd.net/ugc/15198777481553270491/B519DE520D159ED80893DB91993EED7F951C69D7/",
        panic = "https://steamusercontent-a.akamaihd.net/ugc/11230167907497347622/DDC3C6CF61846C37A2E2B0B1AE8F28529D08E73E/",
        decal = "https://steamusercontent-a.akamaihd.net/ugc/16105856831695235391/530814FE4FB047CD9FBC6E4076049134C548849A/",
        scale = 10,
    },

    -- ["Example Champion"] = {
    --     category = "Champion",
    --     accounts = {
    --         "76561198076467336",
    --     },
    --     dice = "https://steamusercontent-a.akamaihd.net/ugc/2474249283050195334/B3431E6883D4727E0DA6A3F4005F5DD40C89BC57/",
    --     scale = 8
    -- },

    ["Circuit - Gold"] = {
        category = "Champion",
        accounts = {
            "76561197988804464", -- Preseason Finals
            "76561198079198972", -- Season 1 Finals
        },
        dice = "https://steamusercontent-a.akamaihd.net/ugc/2399944513746456542/B25B2166E40B09D632AC4C6D1D728A9B20B811E6/",
        panic = "https://steamusercontent-a.akamaihd.net/ugc/2399944513746449918/DD738E1B3E796BDEBBCCA7E791D7C54CD7563281/",
        d3 = "https://steamusercontent-a.akamaihd.net/ugc/2399944513746451601/67419F383E59078FD1D533705F8ABE21E01E2C3E/",
        decal = "https://steamusercontent-a.akamaihd.net/ugc/2481009755930507726/1ACE9BF63B47980A68A5BC60B32F4CC19C3009D9/",
        is3d = true,
        scale = 10,
        rotValues = rotValues3d_d6,
    },
    ["Circuit - Silver"] = {
        category = "Champion",
        accounts = {
            "76561198051704149", -- Welcome to Season 5
            "76561197988804464", -- Hits & Crits Community Vol2
            "76561198209173204", -- Teams Open 2
            "76561198007919710", -- Teams Open 2
            "76561198066032569", -- Teams Open 2
            "76561198024875610", -- Teams Open 2
            "76561198023784704", -- Teams Open 2
            "76561198076467336", -- Teams Open 2, Preseason Finals
            "76561198079198972", -- Feast of the Fallen Stag, Bear & Maiden Fair
            "76561198331984290", -- Negative Elo Brawl
            "76561198043349978", -- A Dream of Spring
            "76561198058168835", -- Disorderly Charge & Failed Panic
            "76561198147651210", -- GOAT of Thrones
        },
        dice = "https://steamusercontent-a.akamaihd.net/ugc/2399944513746454907/B26375D55D66A377B204CCC57DCEED354A42CAE7/",
        panic = "https://steamusercontent-a.akamaihd.net/ugc/2399944513746449918/DD738E1B3E796BDEBBCCA7E791D7C54CD7563281/",
        d3 = "https://steamusercontent-a.akamaihd.net/ugc/2399944513746451601/67419F383E59078FD1D533705F8ABE21E01E2C3E/",
        decal = "https://steamusercontent-a.akamaihd.net/ugc/2481009755930507726/1ACE9BF63B47980A68A5BC60B32F4CC19C3009D9/",
        is3d = true,
        scale = 10,
        rotValues = rotValues3d_d6,
    },
    ["Circuit - Bronze"] = {
        category = "Champion",
        accounts = {
            "76561198032081515", -- LOTN Americas Tournament
            "76561198798152758", -- Preseason Finals
            "76561198036134284", -- LOTN Season 6 Launch
        },
        dice = "https://steamusercontent-a.akamaihd.net/ugc/2399944513746453759/8DAC63876F8B1D834627EE4DC601195BEA93DF03/",
        panic = "https://steamusercontent-a.akamaihd.net/ugc/2399944513746449918/DD738E1B3E796BDEBBCCA7E791D7C54CD7563281/",
        d3 = "https://steamusercontent-a.akamaihd.net/ugc/2399944513746451601/67419F383E59078FD1D533705F8ABE21E01E2C3E/",
        decal = "https://steamusercontent-a.akamaihd.net/ugc/2481009755930507726/1ACE9BF63B47980A68A5BC60B32F4CC19C3009D9/",
        is3d = true,
        scale = 10,
        rotValues = rotValues3d_d6,
    },
}
local DICE_TYPE_TO_ID = {
    ["House"] = "selectDie",
    ["Community"] = "selectCommunityDie",
    ["TSL"] = "selectTslDie",
    ["World Cup"] = "selectWorldCupDie",
}
local ID_CHAMPION_DICE_SELECT = "selectChampionDie"
local ID_DICE_TYPE_SELECT = "diceTypeDropDown"

local ACCOUNTS_CHAMPIONS = {}
for _, values in pairs(TEXTURES) do
    local accounts = values.accounts or {}
    for i, account_id in ipairs(accounts) do
        ACCOUNTS_CHAMPIONS[account_id] = true
    end
end

local d6RotationValues = {{
    value = 1,
    rotation = {
        x = -90,
        y = 0,
        z = 0
    }
}, {
    value = 2,
    rotation = {
        x = 0,
        y = 0,
        z = 0
    }
}, {
    value = 3,
    rotation = {
        x = 0,
        y = 0,
        z = -90
    }
}, {
    value = 4,
    rotation = {
        x = 0,
        y = 0,
        z = 90
    }
}, {
    value = 5,
    rotation = {
        x = 0,
        y = 0,
        z = -180
    }
}, {
    value = 6,
    rotation = {
        x = 90,
        y = 180,
        z = 0
    }
}}
-- FIXME
local d3RotationValues = {{
    value = 1,
    rotation = {
        x = 0,
        y = 90,
        z = 90
    }
}, {
    value = 2,
    rotation = {
        x = 90,
        y = 270,
        z = 0
    }
}, {
    value = 3,
    rotation = {
        x = 0,
        y = 0,
        z = -180
    }
}, {
    value = 4,
    rotation = {
        x = 0,
        y = 90,
        z = 270
    }
}, {
    value = 5,
    rotation = {
        x = 270,
        y = 90,
        z = 0
    }
}, {
    value = 6,
    rotation = {
        x = 0,
        y = 180,
        z = 0
    }
}}

DiceTray = {}
DiceTray.__index = DiceTray
DiceTray.__className = "DiceTray"

setmetatable(DiceTray, {
    __index = GameObjectClass,
    __call = function(cls, gameObj, opts)
        opts = opts or {}
        local this = setmetatable(GameObjectClass(gameObj, cls.__className), DiceTray)

        this.color = opts.color
        this.defaultHouse = opts.defaultHouse
        this.DICE_TYPE_TO_DEFAULT = {
            ["Community"] = "CMON",
            ["TSL"] = "B For Better",
            ["World Cup"] = "World Cup",
        }

        this.zone = opts.zone

        this.diceType = nil
        this.selectedDie = nil
        this.textures = {}

        this.target = 4
        this.amount = 0
        this.maxAmount = 17

        this._isInitialized = false
        this._timer = nil
        return this
    end
})

function DiceTray:getSaveState(opts)
    opts = opts or {}
    local state = {
        color = self.color,
        defaultHouse = self.defaultHouse,
        target = self.target,
        amount = self.amount,
        diceType = self.diceType,
        selectedDie = self.selectedDie,
        zone = self.zone,
        class = self.__className,
    }
    if opts.isCreatingCopy then
        state.amount = 0
        state.zone = nil
    end
    return state
end
function DiceTray:restoreSaveState(savedData)
    self.color = savedData.color
    self.defaultHouse = savedData.defaultHouse
    self.zone = savedData.zone
    self.target = savedData.target
    self.amount = savedData.amount
    self.diceType = savedData.diceType
    self.selectedDie = savedData.selectedDie

    self:setTextures()
    self:updateTextures()
    self:setTarget(self.target)
    self:setAmount(self.amount)

    if self._isInitialized ~= true then
        self:init()
    end
end

function DiceTray:populateDropdownOptions()
    local xml = self.gameObj.UI.getXmlTable()
    for diceType, selectId in pairs(DICE_TYPE_TO_ID) do
        local select = UiUtil.getElementById(xml, selectId)
        local keys = TableUtils.filter(TableUtils.keys(TEXTURES), function(n) return TEXTURES[n].category == diceType end)
        local sortedKeys = table.sort(keys, function (a, b)
            local sortA = TEXTURES[a].sort or 0
            local sortB = TEXTURES[b].sort or 0
            if sortA ~= sortB then
                return sortA < sortB
            end
            return a < b
        end)
        local defaultSelect = self.DICE_TYPE_TO_DEFAULT[diceType] or self.defaultHouse
        select.children = TableUtils.map(sortedKeys, function(key)
            local rendered = {tag = "Option", value = key}
            if key == defaultSelect then
                rendered.attributes = {selected = true}
            end
            return rendered
        end)
    end

    self.gameObj.UI.setXmlTable(xml)
end
function DiceTray:updateChampionshipDiceSelect()
    local steam_id = Player[self.color].steam_id
    local xml = self.gameObj.UI.getXmlTable()

    local select_type = UiUtil.getElementById(xml, ID_DICE_TYPE_SELECT)
    select_type.children = TableUtils.map(TableUtils.keys(DICE_TYPE_TO_ID), function(key)
        local rendered = {tag = "Option", value = key}
            if key == "House" then
                rendered.attributes = {selected = true}
            end
            return rendered
    end)

    if ACCOUNTS_CHAMPIONS[steam_id] then
        table.insert(select_type.children, {tag = "Option", value = "Champion"})
    else
        self.DICE_TYPE_TO_DEFAULT["Champion"] = nil
        self.gameObj.UI.setXmlTable(xml)
        if self.diceType == "Champion" then Wait.frames(function() self:onDiceTypeDropDown_ValueChanged({1, "House", 3}) end, 5) end
        return
    end

    local select_champion = UiUtil.getElementById(xml, ID_CHAMPION_DICE_SELECT)
    local allowed_options = TableUtils.filter(TableUtils.keys(TEXTURES), function(texture_name)
        return TEXTURES[texture_name].category == "Champion" and TableUtils.hasValue(TEXTURES[texture_name].accounts, steam_id)
    end)
    select_champion.children = TableUtils.map(allowed_options, function(opt) return {tag = "Option", value = opt} end)
    select_champion.children[1].attributes = {selected = true}
    self.DICE_TYPE_TO_DEFAULT["Champion"] = select_champion.children[1].value
    self.gameObj.UI.setXmlTable(xml)
end

function DiceTray:createScriptingZone()
    local objSize = self.gameObj.getBounds().size
    local zone = getObjectFromGUID(self.zone)
    if zone == nil then
        zone = spawnObject({
            type = "ScriptingTrigger",
            position = self.gameObj.positionToWorld({0, 9, 0}),
            rotation = self.gameObj.getRotation() + Vector(0, -90, 0),
            scale = {objSize.x - 3, 40, objSize.z - 3},
        })
    end
    self.zone = zone.guid

    local onObjectLeave = function (params)
        local zone, obj = unpack(params)
        if zone.guid ~= self.zone then
            return
        end
        if obj.held_by_color or obj.type ~= "Dice" then
          return
        end
        obj.setVelocity(obj.getVelocity():rotateOver("y", 180))
    end
    EventUtils.register("onObjectLeaveZone", onObjectLeave)
end
function DiceTray:setZonePosition()
    local zone = getObjectFromGUID(self.zone)
    zone.setPosition(self.gameObj.positionToWorld({0, 9, 0}))
    zone.setRotation(self.gameObj.getRotation() + Vector(0, -90, 0))
end

function DiceTray:init()
    self._isInitialized = true
    self:populateDropdownOptions()
    -- Thanks to TTS UI implementation, we would get stale XML data if we ran this function immediately
    Wait.frames(function() self:updateChampionshipDiceSelect() end, 3)
    EventUtils.register("onPlayerChangedColor", function(params)
        self:updateChampionshipDiceSelect()
    end)
    self:createScriptingZone()
    self:initUiEventListeners()
    self:setTextures()

    self._timer = Wait.time(function()
        local dice = self:getDice()
        if not TableUtils.all(dice, function(d) return d.resting end) then
            return
        end
        self:sort()
    end, 0.25, -1)
end
function DiceTray:initUiEventListeners()
    self:register({"onIncreaseDice_Click", "onDecreaseDice_Click", "onDiceCount_ValueChanged"})
    self:register({"onIncreaseTarget_Click", "onDecreaseTarget_Click", "onTargetNumber_ValueChanged"})
    self:register({"onRollDice_Click", "onRollMisses_Click", "onRollHits_Click"})
    self:register({"onDiceTypeDropDown_ValueChanged", "onSelectDie_ValueChanged"})
    self:register({"onRemovePanicDice_Click", "onRollPanicDice_Click"})
    self:register({"onShowPanel_Click", "onHidePanel_Click"})
end
function DiceTray:onDestroy()
    if self._timer ~= nil then
        Wait.stop(self._timer)
    end
    gameObjects[self._guid] = nil
end

function DiceTray:getTargetSliderValue()
    return tonumber(self.gameObj.UI.getAttribute("targetNumberSlider", "value"))
end
function DiceTray:getAmountSliderValue()
    return tonumber(self.gameObj.UI.getAttribute("diceCountSlider", "value"))
end

function DiceTray:onIncreaseDice_Click()
    local amount = self:getAmountSliderValue()
    self:setAmount(math.min(amount + 1, self.maxAmount))
end
function DiceTray:onDecreaseDice_Click()
    local amount = self:getAmountSliderValue()
    self:setAmount(math.max(amount - 1, 0))
end
function DiceTray:onDiceCount_ValueChanged(params)
    local player, value, id = unpack(params)
    self:setAmount(tonumber(value))
end

function DiceTray:onIncreaseTarget_Click()
    local target = self:getTargetSliderValue()
    self:setTarget(math.min(target + 1, 6))
end
function DiceTray:onDecreaseTarget_Click()
    local target = self:getTargetSliderValue()
    self:setTarget(math.max(target - 1, 2))
end
function DiceTray:onTargetNumber_ValueChanged(params)
    local player, value, id = unpack(params)
    self:setTarget(tonumber(value))
end

function DiceTray:setTarget(target)
    self.target = target
    self.gameObj.UI.setValue("targetNumberLabel", "Target  " .. target)
    self.gameObj.UI.setAttribute("targetNumberSlider", "value", target)

    self:countSuccesses()
end
function DiceTray:setAmount(amount)
    self.amount = amount
    self.gameObj.UI.setValue("diceCountLabel", "Dice  " .. amount)
    self.gameObj.UI.setAttribute("diceCountSlider", "value", amount)

    local dice = self:getDice()
    local len = #dice
    for ix = amount + 1, len do
        dice[ix].destruct()
    end
    local spawnGrid = Grid({
        origin = self.gameObj.positionToWorld({-4, 0, -5}),
        columns = self.maxAmount,
        rows = 1,
        rowOffset = self.gameObj.getTransformRight() * -1.1,
        columnOffset = self.gameObj.getTransformForward() * 1.1,
    })
    for ix = len + 1, amount do
        local pos = spawnGrid:posFromIx(ix)
        self:spawnDie(pos)
    end
end

function DiceTray:onRollDice_Click()
    local dice = self:getDice({includePanicDice = true})
    self:onClick_doRoll(dice)
end
function DiceTray:onRollMisses_Click()
    local dice = self:getDice({failures = true})
    self:onClick_doRoll(dice)
end
function DiceTray:onRollHits_Click()
    local dice = self:getDice({successes = true})
    self:onClick_doRoll(dice)
end
function DiceTray:onClick_doRoll(diceToRoll)
    Wait.condition(
        function()
            Wait.time(function() self:doRoll(diceToRoll) end, 0.4)
        end,
        function()
            return TableUtils.all(diceToRoll, function(d) return d.resting end)
        end,
        1 -- timeout after seconds
    )
end
-- opts.includePanicDice
-- opts.resting: only get resting dice
-- opts.successes: only get successes
-- opts.failures: only get failures
function DiceTray:getDice(opts)
    opts = opts or {}
    local zone = getObjectFromGUID(self.zone)
    if zone == nil then
        return {}
    end
    return TableUtils.filter(zone.getObjects(), function (obj, key)
        if obj.type ~= "Dice" then
            return false
        end
        if not opts.includePanicDice and obj.hasTag("PanicDice") then
            return false
        end
        if opts.resting and not obj.resting then
            return false
        end
        if opts.successes and obj.getValue() < self.target then
            return false
        end
        if opts.failures and obj.getValue() >= self.target then
            return false
        end
        return true
    end)
end
function DiceTray:spawnDie(position, value)
    local newDie = nil
    if self.textures.is3d then
        local objParameters = {
            type = "Custom_Assetbundle",
            position = position,
            scale = {x=0.53, y=0.53, z=0.53}
        }
        newDie = spawnObject(objParameters)
        newDie.setCustomObject({
            assetbundle = self.textures.dice,
            type = 2,
            -- TODO: Allow for dynamic material
            material = 2,
        })
    else
        local objParameters = {
            type = "Custom_Dice",
            position = position,
            scale = {x=1.60, y=1.60, z=1.60}
        }
        newDie = spawnObject(objParameters)
        local texture = self.textures.dice
        if type(texture) == "function" then
            texture = texture()
        end
        newDie.setCustomObject({image = texture, type = 1})
    end
    local rotValues = self.textures.rotValues or d6RotationValues
    newDie.setRotationValues(rotValues)
    local toSetValue = value or math.random(1, 6)
    Wait.frames(function()
        newDie.setValue(toSetValue)
    end, 3)
end
function DiceTray:doRoll(diceToRoll)
    for _, die in pairs(diceToRoll) do
        die.setLock(false)
        die.randomize()
        Wait.frames(function() Global.call("castDie", die) end, 1)
    end
end
function DiceTray:sort()
    local dice = self:getDice({resting = true})
    local grids = {}
    for ix = 1, 6 do
        grids[ix] = Grid({
            origin = self.gameObj.positionToWorld({-4.5 + ix * 1.32, -0.12, -3.5}),
            columns = 20,
            rows = 1,
            rowOffset = self.gameObj.getTransformRight() * -1.3,
            columnOffset = self.gameObj.getTransformForward() * 1.3,
        })
    end
    local trayRot = self.gameObj.getRotation()
    for _, die in pairs(dice) do
        local value = die.getValue()
        local gridPos = grids[value]:getNextPos()
        local pos = die.getPosition()
        die.setPosition({gridPos.x, pos.y, gridPos.z})
        local rot = die.getRotation()
        die.setRotation({Utils.round(rot.x / 90) * 90, trayRot.y + 90, Utils.round(rot.z / 90) * 90})
    end
    for val = 1, 6 do
        local count = grids[val]._ix
        local countText = ""
        if count ~= 0 then
            countText = "#" .. val .. ": " .. count
        end
        self.gameObj.UI.setAttribute("resultLabel" .. val, "text", countText)
    end

    self:countSuccesses()
end
function DiceTray:countSuccesses()
    local dice = self:getDice({resting = true})
    if #dice == 0 then
        self.gameObj.UI.setAttribute("totalResultLabel", "text", " ")
    else
        local numSuccesses = TableUtils.count(dice, function (die) return die.getValue() >= self.target end)
        self.gameObj.UI.setAttribute("totalResultLabel", "text", numSuccesses .. " / " .. #dice)
    end
end

function DiceTray:onDiceTypeDropDown_ValueChanged(params)
    local player, type, id = unpack(params)
    self.diceType = type
    self.selectedDie = nil
    self.gameObj.UI.setAttribute("selectDie", "active", type == "House")
    self.gameObj.UI.setAttribute("selectCommunityDie", "active", type == "Community")
    self.gameObj.UI.setAttribute("selectTslDie", "active", type == "TSL")
    self.gameObj.UI.setAttribute("selectWorldCupDie", "active", type == "World Cup")
    self.gameObj.UI.setAttribute("selectChampionDie", "active", type == "Champion")

    self:setTextures()
    self:updateTextures()
end
function DiceTray:onSelectDie_ValueChanged(params)
    local player, selection, id = unpack(params)
    self.selectedDie = selection

    self:setTextures()
    self:updateTextures()
end

function DiceTray:setTextures()
    local type = self.diceType or "House"
    local selected = self.selectedDie or self.DICE_TYPE_TO_DEFAULT[type] or self.defaultHouse or "CMON"
    self.textures = TEXTURES[selected]
    self.diceType = type
    self.selectedDie = selected
end
function DiceTray:updateTextures()
    local dice = self:getDice()
    for _, die in pairs(dice) do
        local pos = die.getPosition()
        local val = die.getValue()
        die.destruct()
        self:spawnDie(pos, val)
    end

    if self.textures.decal ~= nil then
        local rawScale = self.textures.scale or 8
        self.gameObj.setDecals({
            {
                name = "Decal",
                url = self.textures.decal,
                position = {0, -0.36, 0},
                rotation = {90, 270, 0},
                scale    = {rawScale, rawScale, rawScale},
            },
        })
    else
        self.gameObj.setDecals({})
    end
    self:destroyPanicDice(true)
end

function DiceTray:spawnPanicDie(position)
    local newDie = nil
    if self.textures.panic == nil then
        newDie = spawnObject({
            type = "Die_6",
            position = position,
            scale = {x=1.60, y=1.60, z=1.60}
        })
        newDie.setColorTint({r = 0.67, g = 0.0039, b = 0})
    elseif self.textures.is3d then
        local objParameters = {
            type = "Custom_Assetbundle",
            position = position,
            scale = {x=0.53, y=0.53, z=0.53}
        }
        newDie = spawnObject(objParameters)
        newDie.setCustomObject({
            assetbundle = self.textures.panic,
            type = 2,
            -- TODO: Allow for dynamic material
            material = 0,
        })
    else
        newDie = spawnObject({
            type = "Custom_Dice",
            position = position,
            scale = {x=1.60, y=1.60, z=1.60}
        })
        local texture = self.textures.panic
        if type(texture) == "function" then
            texture = texture()
        end
        newDie.setCustomObject({
            image = texture,
            type = 1
        })
    end
    newDie.setName("Panic")
    local rotValues = self.textures.rotValues or d6RotationValues
    newDie.setRotationValues(rotValues)
    -- newDie.setValue(6)
    newDie.setTags({"PanicDice", self.color})
    return newDie
end
function DiceTray:spawnPanicD3(position)
    local d3 = nil
    if self.textures.is3d then
        local objParameters = {
            type = "Custom_Assetbundle",
            position = position,
            rotation = d3RotationValues[3].rotation,
            scale = {x=0.53, y=0.53, z=0.53}
        }
        d3 = spawnObject(objParameters)
        d3.setCustomObject({
            assetbundle = self.textures.d3,
            type = 2,
            material = 0,
        })
    else
        d3 = spawnObject({
            type = "Custom_Dice",
            position = position,
            rotation = d3RotationValues[3].rotation,
            scale = {x=1.60, y=1.60, z=1.60}
        })
        local d3_image = self.textures.d3 or "http://cloud-3.steamusercontent.com/ugc/1035211586490238967/AC2D7342236B216FA0BD9752F275D02517C52584/"
        d3.setCustomObject({
            image = d3_image,
            type = 1
        })
    end
    d3.setName("D3")
    d3.setRotationValues(d3RotationValues)
    -- d3.setValue(2)
    d3.setTags({"PanicDice", self.color})
    return d3
end
function DiceTray:destroyPanicDice(respawn)
    local panicDice = getObjectsWithAllTags({"PanicDice", self.color})

    for _, die in pairs(panicDice) do
        local pos = die.getPosition()
        local name = die.getName()
        die.destruct()
        if respawn ~= nil then
            if name == "D3" then
                self:spawnPanicD3(pos)
            else
                self:spawnPanicDie(pos)
            end
        end
    end
end
function DiceTray:onRemovePanicDice_Click()
    self:destroyPanicDice()
end
function DiceTray:onRollPanicDice_Click()
    self:destroyPanicDice()

    local panicDice = {}
    local d3 = self:spawnPanicD3(self.gameObj.positionToWorld({2.5, 0, 4}))
    table.insert(panicDice, d3)
    for ix = 1, 2 do
        local newDie = self:spawnPanicDie(self.gameObj.positionToWorld(({2.5 - ix, 0, 4})))
        table.insert(panicDice, newDie)
    end

    Wait.frames(function()
        Wait.condition(
            function()
                self:doRoll(panicDice)
            end,
            function()
                return TableUtils.all(panicDice, function(d) return d.resting end)
            end)
    end, 10)
end


function DiceTray:onShowPanel_Click()
    self.gameObj.UI.setAttribute("toggleRollerPanel", "active", "false")
    self.gameObj.UI.show("diceRollingPanel")
    self.gameObj.UI.show("diceTargetPanel")
end
function DiceTray:onHidePanel_Click()
    self.gameObj.UI.hide("diceTargetPanel")
    self.gameObj.UI.hide("diceRollingPanel")
    self.gameObj.UI.setAttribute("toggleRollerPanel", "active", "true")
end

function DiceTray.initDiceTrays()
    local blueTray = getObjectFromGUID(GUIDS["dice_tray"]["Blue"])
    local redTray = getObjectFromGUID(GUIDS["dice_tray"]["Red"])

    local diceTrayBlue = DiceTray(blueTray, {
        color = "Blue",
        defaultHouse = "Stark",
        zone = GUIDS["dice_tray_zone"]["Blue"],
    })

    local diceTrayRed = DiceTray(redTray, {
        color = "Red",
        defaultHouse = "Lannister",
        zone = GUIDS["dice_tray_zone"]["Red"],
    })
    diceTrayBlue:init()
    diceTrayRed:init()
end
