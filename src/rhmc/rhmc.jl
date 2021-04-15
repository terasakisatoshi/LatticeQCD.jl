module Rhmc
    import ..AlgRemez:AlgRemez_coeffs,calc_coefficients

    const coeffs_12 = AlgRemez_coeffs(35.76877880344718, [-2.611603580931762e-6, -2.8381078304162547e-5, -0.00024575851782184877, -0.0020470080999742007, -0.016923799105426088, -0.14034361960343106, -1.1877898203825932, -10.955212949978659, -146.07789284928893, -14714.341373866839], [0.00023220051347978252, 0.0014679843480651033, 0.006577084315568452, 0.027426964178005095, 0.11250019513122003, 0.46049080638938455, 1.8988299965694169, 8.104664281763002, 40.29762890763353, 497.70654517555414], 10)
    const coeffs_m12 = AlgRemez_coeffs(0.027957342505180133, [0.009504168034266293, 0.014392806670277538, 0.02668521749757119, 0.05270932006455869, 0.10589384745339038, 0.2139495082299973, 0.4353956294494188, 0.9089955204708765, 2.107201294600078, 7.749985438494519], [5.143593197266517e-5, 0.0006352731089632578, 0.003158674944452018, 0.013481986300116959, 0.055592857978478315, 0.22755516086118974, 0.9333880277034011, 3.892302237847687, 17.438878032822647, 110.24954086601954], 10)
    const coeffs_14 = AlgRemez_coeffs(6.9461071718499525, [-3.7385105377001425e-6, -1.7764883979837546e-5, -6.334438533952787e-5, -0.00021317868898123004, -0.0007061292823812292, -0.0023271447494456277, -0.007658442853216887, -0.025215367727471134, -0.08325492911813415, -0.27706279011926743, -0.9413396741768589, -3.376769295570277, -14.000699219260555, -87.48968373506541, -2438.159453743938], [7.533204879983615e-5, 0.0004155648337491737, 0.001355472748322587, 0.0038120901090773723, 0.010182414902576235, 0.02668386113490887, 0.06943317053167551, 0.18025949646037842, 0.46811809693900475, 1.219485561990294, 3.205950452609407, 8.636487104246942, 24.866247747939997, 87.21468047228943, 671.5034010759199], 15)
    const coeffs_m14 = AlgRemez_coeffs(0.14396552993778106, [0.00034605541183977854, 0.0007361352806089118, 0.0014491361385218552, 0.002897390997668544, 0.005861553385743302, 0.011923530079141716, 0.0243152683972108, 0.04966483224890658, 0.10166850937810712, 0.20917319384688998, 0.4358756590644266, 0.9388526693245018, 2.2065131459490663, 6.583620229613641, 42.16178846519866], [3.8123410780916776e-5, 0.0002935285649316097, 0.0010295079603283045, 0.002964168149734324, 0.007985151479544388, 0.020992458457826137, 0.054687054756901776, 0.14201748314340246, 0.3686998563362629, 0.959381398013239, 2.5141383694277666, 6.715476095132465, 18.886399620855748, 61.602902654298305, 339.8288033824946], 15)
    const coeffs_18 =AlgRemez_coeffs(2.6226563721874356, [-5.960771208125207e-6, -2.365926748832181e-5, -7.312974957271435e-5, -0.00021647258378734637, -0.0006342614065525487, -0.0018530026882076763, -0.005410134459579222, -0.01580639454625644, -0.04630025630383474, -0.13658135694721724, -0.4103890831099445, -1.2939417075231405, -4.636609634886856, -23.781760392176484, -426.7735702750801], [6.511406585080085e-5, 0.0003827736362029256, 0.001267715019499123, 0.003583090268588116, 0.009587354346137916, 0.02513865988838697, 0.06541997845298224, 0.169826364132841, 0.4409229237078518, 1.1481048390885387, 3.015181840776192, 8.102022022873221, 23.168853584928378, 79.54719981908272, 550.2916347706022], 15)
    const coeffs_m18 = AlgRemez_coeffs(0.3812928032069815, [5.704553583093206e-5, 0.00015212625565764492, 0.000349624141431336, 0.0007978804843345692, 0.0018271691389798897, 0.004194095333537474, 0.009639799649923194, 0.022183627514153276, 0.05116785778935707, 0.11868662341141359, 0.2793062781945737, 0.6824916959670321, 1.8418776768771283, 6.536228531781246, 56.90662030012766], [4.652078712894077e-5, 0.0003218215104770888, 0.0011049316663925537, 0.003159705062233523, 0.00849036686736275, 0.02229761527729769, 0.05806003413186596, 0.15074220148748674, 0.39131776875161906, 1.018351818022971, 2.6701839814977193, 7.144670683970085, 20.193812967613667, 66.8802591890845, 393.15622001947446], 15)

    const coneffs_12_n15 = AlgRemez_coeffs(52.801530615011785, [-6.603122250408879e-7, -4.385050932934162e-6, -2.0643603407379996e-5, -8.956905281940202e-5, -0.00037893462099888793, -0.0015892755651349718, -0.006647330899525596, -0.027809825699088738, -0.11674098552484793, -0.49492401946519393, -2.1537889443543996, -10.04004845875417, -56.31414203731785, -541.0537188024954, -47896.82148291968], [9.76789330722235e-5, 0.0004861285762563459, 0.0015447925188979874, 0.0043078364853888105, 0.011474686157071166, 0.03004933652397656, 0.07819887457469368, 0.20311391670879247, 0.5278790951523255, 1.3769550228941574, 3.6292670454376412, 9.835734487685084, 28.774699349047975, 106.22558098021766, 1108.8405448985493], 15)
    const coneffs_m12_n15 =  AlgRemez_coeffs(0.018938844922720747, [0.006232875919569935, 0.007671885966613157, 0.010882179000141433, 0.016605126881131888, 0.02616286350978532, 0.04176562692239934, 0.06703080125283097, 0.10785465346597474, 0.17392670732092233, 0.28161086985411626, 0.46047137387370596, 0.772252892886211, 1.3840926887668725, 2.9688778021493913, 11.07305624880225], [2.308717887146002e-5, 0.0002409965637633696, 0.000889670459783518, 0.0026027542764653425, 0.007053765864978664, 0.018591747424104358, 0.04849595340124775, 0.1260376463356921, 0.327370440293837, 0.8519322874091946, 2.2309978372893666, 5.942658243141148, 16.571804748421712, 52.66096512396873, 262.08312473142433], 15)

    const coeffs_14_n10 = AlgRemez_coeffs(5.7165557622098175, [-1.1472527436322903e-5, -8.22437195900441e-5, -0.0004911917249478209, -0.0028595740550169564, -0.01657546771377983, -0.09632764566721617, -0.5684080282956644, -3.574637513226843, -29.402805614736042, -910.454747964212], [0.00017585352463504747, 0.0012116676043259563, 0.005511731061457466, 0.023034355065820862, 0.09439559579370578, 0.38561054626048247, 1.5842943313284588, 6.695935386170518, 32.015219356384215, 297.1675517580863], 10)
    const coeffs_m14_n10 = AlgRemez_coeffs(0.17493050738884694, [0.000659835331355923, 0.0018359285824308825, 0.0051025759090143645, 0.014493338675151415, 0.04146036428067062, 0.1190535368426458, 0.3449286017982327, 1.0347965655277906, 3.585219290905995, 23.743072811520367], [8.614668677164346e-5, 0.0007996196969643771, 0.0038232149092825908, 0.01615861364506301, 0.06638822575850153, 0.2711990933978193, 1.1113834065181245, 4.644638810303384, 21.127906621091135, 145.57570030585526], 10)

    const coeffs_m18_n10 = AlgRemez_coeffs(2.3792132499634393, [-1.6178331673230056e-5, -9.324673262980408e-5, -0.0004616164445402523, -0.0022470840473836217, -0.01091397032788275, -0.05314702608352868, -0.26225649448725546, -1.3670670699683314, -8.966025770950466, -176.1213306168453], [0.00015069584886010342, 0.0010969629890608236, 0.005038625333107273, 0.021097078414511326, 0.0864633632847519, 0.35303065630397845, 1.4486843270648686, 6.09968682387749, 28.716462343100822, 241.67613686838126], 10)
    const coeffs_18_n10 = AlgRemez_coeffs(0.4203070069550793, [0.00012205466614334875, 0.0004400966659764438, 0.0014872525305126727, 0.005058114989269569, 0.017260926270113545, 0.05909197271336461, 0.20435471009883857, 0.7359818587930066, 3.136603644754106, 28.83640562962562], [0.0001059268835215699, 0.0008914747121053526, 0.004196936783670219, 0.017671206571184022, 0.07251494889428817, 0.29607916032240045, 1.2134381593989532, 5.080750861110906, 23.33715928002066, 169.8786011269988], 10)

    const coeffs_316_n10 = AlgRemez_coeffs(3.6809859856076006, [-1.4492439436302e-5, -9.325476513375239e-5, -0.0005071773835707172, -0.0026999592253987474, -0.014325236111130017, -0.07620155177935224, -0.41114554274869747, -2.35339815434199, -17.267065062531614, -422.4465412221929], [0.00016303402995984946, 0.0011532592270673625, 0.0052705350023899665, 0.022045664212880994, 0.0903433419964063, 0.36894937239787706, 1.5148499066294283, 6.3897804653772265, 30.306897030377673, 267.14586644977305], 10)
    const coeffs_m316_n10 =AlgRemez_coeffs(0.27166634263480777, [0.00030127966033026253, 0.0009568206736816092, 0.002933718947418554, 0.009119086793578451, 0.028492150876835938, 0.08933146506111686, 0.28275207514646944, 0.9292775534445537, 3.568717153874218, 27.75108312820713], [9.582779752578782e-5, 0.0008446922155818269, 0.004006397424561391, 0.016899364014855124, 0.06938621370628821, 0.2833634381271653, 1.1612260693439331, 4.857191914747077, 22.197958099237212, 157.02243271729554], 10)

    const coeffs_316_n15 = AlgRemez_coeffs(4.2601351799946645, [-5.023302802829547e-6, -2.1843311323189485e-5, -7.254415803782998e-5, -0.0002289965679798019, -0.0007134236414181523, -0.0022137164653857557, -0.006861858446079219, -0.02128182783145359, -0.06618296999948652, -0.207357120165794, -0.6624861478137918, -2.227666341673426, -8.583213356909058, -48.53180515400818, -1076.3618464670292], [7.014496443573226e-5, 0.00039896918707646683, 0.0013110417415338306, 0.0036960849688970486, 0.009880823466054303, 0.02590035710683382, 0.06739735489315007, 0.1749645841058223, 0.45430953626678655, 1.1832196715749264, 3.10894106240096, 8.364243408717298, 23.998297315757416, 83.25209805059654, 605.9438836424484], 15)
    const coeffs_m316_n15 = AlgRemez_coeffs(0.2347343353553519, [0.00014920674448005303, 0.0003563945408705788, 0.000758549665008001, 0.0016206595372869222, 0.0034885648102461727, 0.007538469145878805, 0.016320652512563715, 0.03538372896378343, 0.07688666469222608, 0.1679598441650826, 0.3719256994781029, 0.8531787934463007, 2.1481488833037776, 6.9844905769574215, 51.96265478033731], [4.224813665271006e-5, 0.00030749975795734996, 0.0010667423468910398, 0.0030606474189069427, 0.008234314992201796, 0.02163588099065754, 0.05634924639787175, 0.14631532507468242, 0.3798368651200859, 0.9884033604017544, 2.5908771761735383, 6.926247695988255, 19.52645685411185, 64.16535619602493, 364.9584857007813], 15)

    const coeffs_116_n10 = AlgRemez_coeffs(1.5415518868736153, [-1.3479430121943058e-5, -6.94201538082298e-5, -0.0003126661939194834, -0.0013916886233759954, -0.006188076237322275, -0.027589016753023186, -0.1245324898468633, -0.5914596709482897, -3.4742286716222375, -55.54678127697615], [0.00013882712073814147, 0.0010427057329816902, 0.004815645332230554, 0.020186910321409287, 0.0827478002270612, 0.3378178395072549, 1.3856209433222577, 5.824639577289666, 27.23321780251678, 219.83080818097415], 10)
    const coeffs_m116_n10 = AlgRemez_coeffs(0.6486969452764099, [3.700042842098551e-5, 0.00015079448163203167, 0.0005611926716449521, 0.0020879435883160474, 0.0077820860771356136, 0.029091606762512965, 0.10993281201125081, 0.4340071720814183, 2.0553558161578303, 22.51375139207575], [0.00011645319512688589, 0.0009400284676471159, 0.004395121734195312, 0.018475471320908106, 0.07578048583029384, 0.30937378310665936, 1.2681484978337598, 5.316006107979378, 24.551509779077374, 184.40200923195147], 10)

    const coeffs_116_n15 = AlgRemez_coeffs(1.6185000680192376, [-5.275675561552804e-6, -1.905943830174897e-5, -5.478386501649487e-5, -0.00015202846127429466, -0.0004188910583023452, -0.0011522244219551656, -0.0031687543411440307, -0.008721356054902667, -0.024063908877878376, -0.06684019299723166, -0.1889040831737245, -0.5586308875508903, -1.862986712921942, -8.688215410720257, -127.95388494297556], [6.023769511309328e-5, 0.0003669695054114907, 0.0012254661358547714, 0.0034730288868307802, 0.00930178587200822, 0.02439813812025899, 0.06349925407787103, 0.16483979007187546, 0.4279439408590773, 1.1140995783995267, 2.9245453049405072, 7.849370085647775, 22.3756796801671, 76.0768845108769, 502.52795266083274], 15)
    const coeffs_m116_n15 =AlgRemez_coeffs(0.6178560135767099, [1.6310151533358196e-5, 4.832257950125254e-5, 0.00011977943286380154, 0.00029186384567718237, 0.0007109672662139922, 0.0017334632661060681, 0.004229776095431311, 0.010332011458502688, 0.025297423528509576, 0.06230869743700897, 0.15584518249535737, 0.4057262213366748, 1.174289038326619, 4.555909744162507, 46.80220939431267], [5.094243984727753e-5, 0.0003365016872679626, 0.0011440993241734155, 0.00326140820481996, 0.008753497494722783, 0.022978197367937252, 0.059820919414372856, 0.15530230891969457, 0.4031543420747268, 1.0492603933061206, 2.7521596768893435, 7.371087553308721, 20.89001013654598, 69.76056490387172, 424.9830600579467], 15) 


    const coeffs_38_n10 = AlgRemez_coeffs(14.032828673577047, [-5.930471386844274e-6, -5.249034334202079e-5, -0.00037766559307773336, -0.0026295890024527822, -0.018198590793797723, -0.12629023185141475, -0.8919733058167283, -6.783663999961085, -70.6380847108092, -3725.110827418723], [0.00020298654720113192, 0.0013351272311909414, 0.006023489042020999, 0.02513922675688908, 0.10305054546222052, 0.42131759133882224, 1.733786698287018, 7.360926272951278, 35.83579250165611, 376.4480662247984], 10)
    const coeffs_m38_n10 = AlgRemez_coeffs(0.07126147003297621, [0.002659984067675914, 0.005566149503394092, 0.012669205231737415, 0.030026900325213806, 0.07199470450611001, 0.1734151948594954, 0.4210503400166998, 1.0533219869109964, 2.9797791991044296, 14.5648052061407], [6.800406828152703e-5, 0.0007143695789291371, 0.0034778231775083363, 0.01476536878803651, 0.060761763871882986, 0.248421780643415, 1.0183288550426342, 4.250028483725888, 19.17420257930374, 126.11673213315908], 10)

    const coeffs_58_n10 = AlgRemez_coeffs(97.26497431269344, [-1.007469384641391e-6, -1.3386535465427254e-5, -0.00013942426924235733, -0.001389817230580669, -0.013736158506036026, -0.13623801102629404, -1.3835325478601752, -15.527236289001818, -268.88390324035515, -62261.283349000536], [0.0002636099164974018, 0.0016109320470394626, 0.007175997589553093, 0.0299144352285052, 0.12282482017026194, 0.5035121167155298, 2.081333558150099, 8.93903213958087, 45.559156297451935, 703.5181978030724], 10)
    const coeffs_m58_n10 =AlgRemez_coeffs(0.010281193277090048, [0.03182419183885205, 0.03277203765655622, 0.049159012643237764, 0.08079714113313465, 0.1359466247564687, 0.2303472367124537, 0.3929036494259198, 0.684957768483517, 1.3049796445178938, 3.667738443775162], [3.638853988417498e-5, 0.0005619068060185254, 0.00286384472057624, 0.012299806486930154, 0.05084286782807114, 0.20842692840512883, 0.8557741372835946, 3.567448244027953, 15.89142139610864, 97.11319035394607], 10)

    const coeffs_516_n15 =AlgRemez_coeffs(11.385541027213957, [-2.5883990136186256e-6, -1.34107963702085e-5, -5.1305022750383463e-5, -0.00018403727430983343, -0.0006480993109305678, -0.0022685391428745247, -0.007926337469655412, -0.027705911719169148, -0.09712862656012108, -0.34335602958570954, -1.2407498008705067, -4.749596848376581, -21.208578393694413, -146.87357279994382, -5244.956733611847], [8.067707940961776e-5, 0.0004325694384053837, 0.0014010351574290606, 0.003931185020736206, 0.010492357283010274, 0.027489824654688577, 0.07152927679994464, 0.18571634020264421, 0.482363504952572, 1.256945813827612, 3.3063437707307237, 8.919233063854097, 25.775125213469988, 91.46117039274736, 749.7290740634378], 15)
    const coeffs_m516_n15 =AlgRemez_coeffs(0.0878306966361791, [0.0007509277962442122, 0.0014129771103351901, 0.0025690642606846677, 0.004804704680853413, 0.009133835322768288, 0.017489465723451957, 0.03359412543590045, 0.06464533476923524, 0.12467226990157802, 0.24158352510716458, 0.47376218666651115, 0.9583492339226309, 2.103423848192116, 5.767769271520715, 32.00338130302361], [3.414566792941776e-5, 0.0002799002012555704, 0.0009932056503307125, 0.002870201935158085, 0.007742691557551572, 0.020366828640006118, 0.05307200842758016, 0.13784462892207863, 0.3578954121345152, 0.9312536664592276, 2.439871166172806, 6.512031325151368, 18.272203851741118, 59.181249822852465, 317.3144118172943], 15)

    const coeffs_716_n15 =AlgRemez_coeffs(31.313197770970913, [-1.0793214732696161e-6, -6.609525631069224e-6, -2.905266889459055e-5, -0.00011832919708565384, -0.00047093001543932836, -0.001859542777802144, -0.007324798573105492, -0.028860675260254678, -0.11408254589714387, -0.4551842257788603, -1.8615313222732597, -8.123102336434437, -42.18571390497898, -362.1399905644311, -22908.575751045388], [9.18485167615663e-5, 0.0004678419477166609, 0.001495666144301569, 0.004178972999211195, 0.01113824571344111, 0.029171852531255857, 0.07591010443427565, 0.19713779123944156, 0.5122275275730622, 1.335632265381022, 3.517850872464474, 9.518299441967585, 27.726378456762344, 100.92979716585268, 961.3902264441133], 15)
    const coeffs_m716_n15 =AlgRemez_coeffs(0.031935416092413786, [0.0031537964827845935, 0.004523479906318463, 0.006982550569387302, 0.011408753013703721, 0.019140376596269052, 0.032467464921531894, 0.05532588334038562, 0.09449344790923538, 0.1617452326920084, 0.27804374861930287, 0.48301182539416243, 0.862159797570612, 1.652538890256914, 3.842438751470821, 16.279516536550958], [2.6628105108459994e-5, 0.0002536416471533462, 0.0009233084674192736, 0.002689556065774295, 0.007277170331573949, 0.01916695235922365, 0.04997779038017147, 0.12985840938486778, 0.3372410061978633, 0.8775582549161446, 2.2983870762616716, 6.125907012280805, 17.116119193802056, 54.71933443536391, 278.71979758210136], 15)

    const coeffs_78_n10 =AlgRemez_coeffs(1230.7719922257754, [-7.817436007295994e-8, -1.5398021609880276e-6, -2.3190014141727902e-5, -0.00033171176364069267, -0.004697430148092109, -0.06685632163466347, -0.9823098960589322, -16.530089305894354, -511.16599403729646, -2.920627728485016e6], [0.0003335200885599715, 0.0019301557290464593, 0.008525380241714172, 0.035565228835393155, 0.146468332579182, 0.6028801585440726, 2.5078222334346627, 10.939452955175021, 59.42578612318403, 2393.738561025292], 10)
    const coeffs_m78_n10 =AlgRemez_coeffs(0.0008124981770112931, [0.32236862575088493, 0.09154657032332804, 0.08736027363216234, 0.09878363843685596, 0.11633502625015543, 0.1384850370099463, 0.1658592335867067, 0.20179179005458292, 0.2614027908690245, 0.44447806728898276], [1.0694568077240211e-5, 0.00043078942105929615, 0.0023401535803387373, 0.010208060068491684, 0.04246283384383194, 0.17478180811651173, 0.7198041693611674, 3.0027986170916754, 13.26317851702411, 76.75699568962177], 10)

    const coeffs_34_n10 =AlgRemez_coeffs(298.58720499477124, [-3.299101948582033e-7, -5.343176675575475e-6, -6.691835387626825e-5, -0.0007987743389585288, -0.00944538212770885, -0.11215721771054094, -1.3687895490220674, -18.766585249990396, -429.50705022860484, -322534.27299739956], [0.00029733856237739, 0.0017647191251857377, 0.007824038043560863, 0.03262029939367273, 0.13411408952863116, 0.5508126601932356, 2.2834892835910865, 9.878246105384765, 51.83533147717517, 1121.8951948139681], 10)
    const coeffs_m34_n10 =AlgRemez_coeffs(0.003349105330945148, [0.10250175133410291, 0.06394086808888692, 0.07692819871571034, 0.10500227685207546, 0.14786976782579872, 0.2100538823110672, 0.3002674185903645, 0.4372636075937648, 0.6862910593983804, 1.4926337354888635], [2.281853074898407e-5, 0.0004938716367864367, 0.0025915531691445815, 0.011210913133667372, 0.046476782125921066, 0.1908822562191337, 0.7847874015823891, 3.271967730405996, 14.506557805512303, 86.09714056365083], 10)

    const coeffs_38_n15=AlgRemez_coeffs(18.79461012834135, [-1.7046360675558396e-6, -9.610444656158535e-6, -3.942131666362604e-5, -0.0001506945528158633, -0.0005641655383593682, -0.0020973965186186732, -0.007780906711025815, -0.028875180111212696, -0.10748670775823455, -0.4036619555800518, -1.5516514552511727, -6.3405809684551775, -30.519208440243514, -234.92699627297367, -11006.565500273748], [8.618191632608366e-5, 0.00044999205720852386, 0.001447756780073927, 0.004053451322420477, 0.010810886447089106, 0.028318922501614753, 0.07368759207257308, 0.19134055525396876, 0.4970612673774702, 1.2956456408246217, 3.41026142515494, 9.21299036770491, 26.72755284565795, 96.02146305474176, 844.4911661436578], 15)
    const coeffs_m38_n15 =AlgRemez_coeffs(0.05320674348504038, [0.001561750230863162, 0.00257837609723268, 0.004323195247122347, 0.007559234131636582, 0.013501089188020132, 0.02433298126687033, 0.04402353307877137, 0.07981060819389385, 0.14500783100849374, 0.26465315222557295, 0.4884655289370063, 0.928106060143738, 1.903223926786511, 4.802681253420789, 23.224659637688003], [3.0314112244538444e-5, 0.0002666070603965435, 0.000957813090776804, 0.0027786852019012083, 0.00750675587835232, 0.019758488890300845, 0.05150270536078457, 0.13379285936544294, 0.3474126278246031, 0.9039891965713133, 2.367983432745513, 6.315605631773869, 17.68252813755967, 56.88989303234991, 297.0460752246229], 15)

    """
    f(x) = x^(y/z) = coeffs.α0 + sum_i^n coeffs.α[i]/(x + coeffs.β[i])
    f(x) = x^(-y/z) = coeffs_inverse.α0 + sum_i^n coeffs_inverse.α[i]/(x + coeffs_inverse.β[i])
    """
    struct RHMC #type for the rational Hybrid Monte Carlo
        y::Int64
        z::Int64
        coeffs::AlgRemez_coeffs
        coeffs_inverse::AlgRemez_coeffs

        function RHMC(order::Rational;n=10,lambda_low=0.0004,lambda_high=64,precision=42)
            num = numerator(order)
            den = denominator(order)
            return RHMC(num,den,n=n,lambda_low=lambda_low,lambda_high=lambda_high,precision=precision)
        end

        function RHMC(y,z;n=10,lambda_low=0.0004,lambda_high=64,precision=42)
            println("-------------------------------------------------------------")
            println("RHMC mode!")
            
            order = y // z # y/z
            num = numerator(order)
            den = denominator(order)
            @assert num != 0 "numerator should not be zero!"
            @assert num*den != 1 "$(num ÷ den) should not be 1!"
             
            if n == 10 && num == 1 && den == 2
                coeffs =coeffs_12
                coeffs_inverse =coeffs_m12
            elseif n == 10 && num == 3 && den == 8
                    coeffs =coeffs_38_n10
                    coeffs_inverse =coeffs_m38_n10
            elseif n == 10 && num == 5 && den == 8
                    coeffs =coeffs_58_n10
                    coeffs_inverse =coeffs_m58_n10
            elseif n == 10 && num == 7 && den == 8
                    coeffs =coeffs_78_n10
                    coeffs_inverse =coeffs_m78_n10
            elseif n == 10 && num == 3 && den == 4
                    coeffs =coeffs_34_n10
                    coeffs_inverse =coeffs_m34_n10
            elseif n == 15 && num == 3 && den == 16
                    coeffs =coeffs_316_n15
                    coeffs_inverse =coeffs_m316_n15
            elseif n == 15 && num == 5 && den == 16
                    coeffs =coeffs_516_n15
                    coeffs_inverse =coeffs_m516_n15
            elseif n == 15 && num == 7 && den == 16
                    coeffs =coeffs_716_n15
                    coeffs_inverse =coeffs_m716_n15
            elseif n == 15 && num == 1 && den == 16
                    coeffs =coeffs_116_n15
                    coeffs_inverse =coeffs_m116_n15
            elseif n == 15 && num == 1 && den == 2
                    coeffs =coeffs_12_n15
                    coeffs_inverse =coeffs_m12_n15

            elseif n == 15 && num == 3 && den == 8
                coeffs =coeffs_38_n15
                coeffs_inverse =coeffs_m38_n15
            elseif n == 15 && num == 1 && den == 4
                coeffs =coeffs_14
                coeffs_inverse =coeffs_m14
            elseif n == 10 && num == 1 && den == 4
                coeffs =coeffs_14_n10
                coeffs_inverse =coeffs_m14_n10
            elseif n == 15 && num == 1 && den == 8
                coeffs =coeffs_18
                coeffs_inverse =coeffs_m18
            elseif n == 10 && num == 1 && den == 8
                coeffs =coeffs_18_n10
                coeffs_inverse =coeffs_m18_n10
            elseif n == 10 && num == -1 && den == 2
                coeffs =coeffs_m12
                coeffs_inverse =coeffs_12
            elseif n == 15 && num == -1 && den == 2
                coeffs =coeffs_m12_n15
                coeffs_inverse =coeffs_12_n15
            elseif n == 15 && num == -1 && den == 4
                coeffs =coeffs_m14
                coeffs_inverse =coeffs_14
            elseif n == 10 && num == -1 && den == 4
                coeffs =coeffs_m14_n10
                coeffs_inverse =coeffs_14_n10
            elseif n == 15 && num == -1 && den == 8
                coeffs =coeffs_18
                coeffs_inverse =coeffs_18
            elseif n == 10 && num == -1 && den == 8
                coeffs =coeffs_18_n10
                coeffs_inverse =coeffs_18_n10
            else
                println("$y//$z with the order $n: coefficients for RHMC should be calculated")
                coeff_plus,coeff_minus = calc_coefficients(abs(num),den,n,lambda_low,lambda_high,precision=precision)
                if num > 0
                    coeffs =coeff_plus
                    coeffs_inverse =coeff_minus
                elseif num < 0
                    coeffs_inverse =coeff_plus
                    coeffs =coeff_minus
                end
            end

            println("the coefficients for x^{$num/$den}: ")
            display(coeffs)
            println("the coefficients for x^{-$num/$den}: ")
            display(coeffs_inverse)
            println("-------------------------------------------------------------")

            return new(num,den,coeffs,coeffs_inverse)
        end
    end

    function get_α(x::RHMC)
        return x.coeffs.α
    end

    function get_α0(x::RHMC)
        return x.coeffs.α0
    end

    function get_β(x::RHMC)
        return x.coeffs.β
    end

    function get_order(x::RHMC)
        return x.coeffs.n
    end

    function get_α_inverse(x::RHMC)
        return x.coeffs_inverse.α
    end

    function get_α0_inverse(x::RHMC)
        return x.coeffs_inverse.α0
    end

    function get_β_inverse(x::RHMC)
        return x.coeffs_inverse.β
    end



end