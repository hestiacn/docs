<template>
  <div class="not-found">
    <canvas ref="snowCanvas" class="snow"></canvas>
    
    <div class="main-content">
      <div class="scene-wrapper">
        <div class="scene" data-hover-only="false">
          <div class="circle" data-depth="1.2"></div>

          <div class="one" data-depth="0.9">
            <div class="content">
              <span class="piece"></span>
              <span class="piece"></span>
              <span class="piece"></span>
            </div>
          </div>

          <div class="two" data-depth="0.60">
            <div class="content">
              <span class="piece"></span>
              <span class="piece"></span>
              <span class="piece"></span>
            </div>
          </div>

          <div class="three" data-depth="0.40">
            <div class="content">
              <span class="piece"></span>
              <span class="piece"></span>
              <span class="piece"></span>
            </div>
          </div>

          <p class="p404" data-depth="0.50">404</p>
          <p class="p404" data-depth="0.10">404</p>
        </div>
      </div>
      
      <div class="message-section">
        <p id="error-message">{{ errorMessage }}</p>
        
        <a href="/" class="home-link">
          <i class="fa-solid fa-house home-icon"></i>
          返回首页
        </a>
      </div>
      
      <div class="time-display-bottom">
        当前时间: 公元{{ currentDateTime }}
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted, onUnmounted, ref } from 'vue'

export default {
  name: 'NotFound',
  setup() {
    const snowCanvas = ref(null)
    const currentDateTime = ref('')
    const particles = ref([])
    const animationFrameId = ref(null)
    const ctx = ref(null)
    const scene = ref(null)
    const errorMessage = ref('')

    const messages = [
      "🐉 页面跟着哪吒去闹海，被龙王追着跑！",
      "🏮 页面跑去逛元宵灯会，猜灯谜猜到头秃！",
      "🧧 页面贴春联贴到忘我，把自己贴门上了！",
      "🐼 页面被熊猫当竹子叼走，挂在树上晃悠！",
      "☯ 页面困在太极图里，转晕了找不到出口！",
      "👤 页面跟着皮影戏巡演，被线缠住当了一回主角！",
      "🌕 页面陪嫦娥捣仙药，手都捣酸了！",
      "🎋 页面穿越回长安看花灯，挤进人堆出不来了！",
      "🌸 页面在西湖边赏桃花，被花瓣糊了一脸！",
      "🏯 页面去蓬莱仙岛闭关，结果睡着了！",
      "🌉 页面帮牛郎搭鹊桥，被喜鹊啄得满头包！",
      "📜 页面被孔夫子留下抄书，毛笔都写秃了！",
      "🦚 页面随孔雀舞巡游云南，被孔雀尾巴扇飞了！",
      "🏮 页面混入天灯节飞向银河，差点被星星撞到！",
      "🦁 页面被舞狮队叼去采青，挂在竹竿上下不来了！",
      "🎭 页面在梨园客串青衣，唱跑了三个观众！",
      "🪁 页面追着纸鸢翻越秦岭，风筝线缠住了树！",
      "⛩️ 页面在武当山论道忘归，被道长拉着打太极！",
      "🪕 页面跟着刘三姐对山歌，嗓子都喊哑了！",
      "🀄 页面被麻将牌砌成长城，自己成了里面的砖！",
      "🎵 页面在听周杰伦的《青花瓷》，跟着哼跑调了！",
      "🛒 页面在直播间抢茅台，手速太慢没抢到！",
      "🚄 页面坐着复兴号环游中国，坐过站了！",
      "📱 页面在微信群里抢红包，抢到一分钱！",
      "🌾 页面帮神农尝百草，苦得脸都绿了！",
      "🏺 页面在敦煌临摹飞天壁画，颜料糊了一身！",
      "🎑 页面偷吃供月糕被玉兔追，跑掉了鞋子！",
      "🪔 页面在秦淮河放莲花灯，把自己放河里的灯一起漂走了！",
      "🏯 页面在阆中古城陪落下闳研究春节和农历，学到了闰月是怎么回事！",
      "🗡️ 页面跟着荆轲刺秦王，在咸阳宫迷路了！",
      "📖 页面在岳阳楼背诵《岳阳楼记》，背到一半忘词了！",
      "🐲 页面被屈原拉去汨罗江投粽子，粽子太大扔不动！",
      "🌊 页面帮大禹治水三过家门而不入，饿得肚子咕咕叫！",
      "✂️ 页面在蔚县学习剪纸窗花，剪出了个四不像！",
      "🪡 页面被蜀绣针法绕成中国结，解不开了！",
      "🪁 页面追着潍坊风筝飞进云彩里，在天上下不来了！",
      "🍶 页面在景德镇当青花瓷模特，被画成了花瓶！",
      "🎆 页面带着火把去过彝族新年，差点把自己点着了！",
      "🏮 页面跑去自贡灯会，被巨型瓷器灯震撼到合不拢嘴！",
      "🍡 页面在冬至集市卖糖画，画出来的糖人像外星人！",
      "🥮 页面被嫦娥拉去广寒宫找玉兔，被桂花树绊倒了！",
      "🏔️ 页面在珠峰大本营堆玛尼堆，堆到一半缺氧了！",
      "🌋 页面被长白山天池水怪拖下水，发现水怪是只大蛤蟆！",
      "🏞️ 页面在黄果树瀑布冲彩虹浴，被水冲走了拖鞋！",
      "🛶 页面划着独木舟穿越三峡悬棺，吓得闭眼划船！",
      "🚀 页面穿着汉服登陆空间站，被失重飘了起来！",
      "🤖 页面在教故宫机器人打太极拳，机器人卡住了！",
      "📱 页面被二维码吸进《清明上河图》，找不到出来的码！",
      "🍜 页面在兰州拉面里跳毛细舞，被拉面师傅当成面条甩！",
      "⚔️ 页面学关羽温酒斩华雄，酒凉了还没砍到！",
      "🍶 页面陪李白金樽清酒斗十千，喝到桌子底下去了！",
      "🍲 页面在重庆火锅的红油锅里涮自己，辣到起飞！",
      "🍵 页面去潮汕功夫茶馆当茶宠，被茶水浇得浑身茶香！",
      "🐼 页面爬上成都太古里的3D大屏看风景，被路人当成屏幕里的一部分！",
      "🥯 页面在天津排队买狗不理包子，排到发现卖完了！",
      "🧊 页面在哈尔滨冰雪大世界被冻成冰雕，游客围着他拍照！",
      "🦆 页面在北京排队买烤鸭，排到最后一位，烤鸭卖光了！",
      "🐹 页面在新疆巴音布鲁克草原和土拨鼠对叫，土拨鼠赢了！",
      "🍜 页面在柳州螺蛳粉里被酸笋熏晕，被老板抬到门口透气！",
      "🧆 页面在长沙南门口吃臭豆腐去了，正被刚出锅的黑皮爆汁烫得嗷嗷叫，嘴里还含糊不清地喊：老板再来一份！",
      "🍜 页面在沙县小吃点了碗扁肉，一口咬下去，肉馅鲜嫩飙汁，烫得直哈气还不肯停嘴！",
      "🦀 页面在阳澄湖蹲在蟹笼边，正和胖螃蟹大眼瞪小眼，学人家吐泡泡玩呢！",
      "🍍 页面在徐闻「菠萝的海」摘菠萝，满手都是菠萝香，连衣服都腌入味了！",
      "🍖 页面在淄博烧烤摊上熟练地小饼卷肉串加小葱，咬得满嘴流油，还喊老板加单！",
      "🎋 页面在五芳斋学裹大肉粽，手被糯米粘得全是米粒，绑绳子绑成了蝴蝶结！",
      "☕ 页面在上海梧桐树下排队三小时买咖啡，喝了一口说：值了！",
      "🍢 页面在长沙坡子街派出所门口拍照打卡，摆出‘我自首’的姿势笑疯了！",
      "🎰 页面在澳门大三巴牌坊下吃葡式蛋挞，烫得直吹气，蛋挞皮碎了一胸脯！",
      "🍵 页面在杭州龙井茶园里跟着阿姨采茶青，手忙脚乱把嫩芽掐成了碎片！",
      "🧺 页面在婺源的晒秋大笸箩里当红辣椒，被太阳晒得蔫儿了还在傻笑！",
      "🏺 页面在景德镇的古窑里闭关烧瓷器，满身都是泥巴，烧出一只歪脖子花瓶！",
      "🍖 页面去哈尔滨红肠车间观摩纯手工果木熏制，因为太香，正趴在熏炉边上和红肠一起‘两眼冒烟’呢！",
      "🍜 页面在武汉户部巷吃热干面，被芝麻酱糊了一嘴！",
      "🏯 页面在平遥古城换上晋商少奶奶的衣服，拍照拍得停不下来！",
      "🏯 页面在西安大唐不夜城看不倒翁小姐姐跳舞，跟着摇差点摔倒！",
      "🐑 页面在呼伦贝尔大草原跟羊群玩捉迷藏，被羊当成同类了！",
      "🎋 页面在蜀南竹海里闭关修炼绝世武功，被竹子绊倒十八次！",
      "🏔️ 页面爬上玉龙雪山顶，吸氧吸到上头！",
      "🏹 页面跟着后羿去射日，拉弓拉到手抖！",
      "🧱 页面在雷峰塔帮许仙一起救白娘子，被法海的金钵罩住了！",
      "🧱 页面在长城脚下看孟姜女大哭被秦始皇抓去修长城累死的丈夫，直接把长城哭塌了三百里！",
      "🪓 页面陪沉香去华山劈山救母，山没劈开自己先累趴了！",
      "📖 页面蹲在兰亭边向王羲之讨教《兰亭集序》的笔法，学完反手就把他的大白鹅给炖了，现正和王羲之被绍兴花雕酒灌得烂醉呢！",
      "🧚‍♂️ 页面被八仙拉去组团横渡蓬莱东海，被浪打得直喝海水！",
      "🔥 页面在火焰山找铁扇公主借芭蕉扇，被热得直冒汗！",
      "🐒 页面在花果山陪猴子们吃水蜜桃，被猴王当成了新来的小猴！",
      "🩺 页面陪华佗研究麻沸散的配方，试药试得舌头麻了三天！",
      "🛖 页面在杜甫的草堂里帮忙修屋顶，被茅草扎得满手刺！",
      "🐎 页面跟着木兰替父从军去塞外，骑马骑得大腿磨破皮！",
      "⛺ 页面跟着诸葛亮在军营帐篷里商议借东风，听八卦阵听得头昏脑涨！",
      "🐔 页面被祖逖拉起来闻鸡起舞，困得闭着眼睛比划！",
      "🪞 页面在帮魏征当镜子正衣冠，被唐太宗夸照得清楚！",
      "🗡️ 页面在鸿门宴上看项庄舞剑，吓得躲到桌子底下！",
      "🎭 页面在垓下看霸王别姬，哭得比虞姬还伤心，项羽都来安慰他！",
      "🧭 页面跟着郑和下西洋，在甲板上吹海风，被晒成小黑炭！",
      "🧪 页面和李时珍在神农架采灵芝，被毒蛇追着跑！",
      "🦋 页面分不清自己是庄周还是蝴蝶，干脆躺着做梦去了！",
      "🐠 页面在濠梁之上和庄子辩论鱼乐不乐，被庄子绕晕了！",
      "📖 页面在函谷关帮老子研墨写《道德经》，研到手抽筋！",
      "🪙 页面帮沈万三往聚宝盆里扔硬币，扔到手软盆还没满！",
      "🏯 页面在阿房宫里迷路，转了三天找不到出口，饿得啃柱子！",
      "🎬 页面被电影《百鸟朝凤》中'焦家班'代代坚守的唢呐精神所震撼，正观摩师徒传承非遗文化呢！",
    ]

    const getRandomMessage = () => {
      return messages[Math.floor(Math.random() * messages.length)]
    }

    const updateDateTime = () => {
      const now = new Date()
      const year = now.getFullYear()
      const month = String(now.getMonth() + 1).padStart(2, '0')
      const day = String(now.getDate()).padStart(2, '0')
      const hour = String(now.getHours()).padStart(2, '0')
      const minute = String(now.getMinutes()).padStart(2, '0')
      const second = String(now.getSeconds()).padStart(2, '0')
      currentDateTime.value = `${year}年${month}月${day}日 ${hour}:${minute}:${second}`
    }

    const initSnow = () => {
      if (!snowCanvas.value) return
      snowCanvas.value.width = window.innerWidth
      snowCanvas.value.height = window.innerHeight
      ctx.value = snowCanvas.value.getContext('2d')
      createParticles()
      animate()
    }

    const createParticles = () => {
      const particleCount = Math.min(200, (window.innerWidth * window.innerHeight) / 7000)
      particles.value = Array.from({ length: particleCount }, () => ({
        x: Math.random() * window.innerWidth,
        y: Math.random() * -window.innerHeight,
        dx: (Math.random() * 2) - 1,
        dy: (Math.random() * 1.5) + 1.2,
        size: Math.random() * 4 + 3,
        points: 5 + Math.floor(Math.random() * 3),
        angle: Math.random() * Math.PI * 2,
        rotation: (Math.random() - 0.5) * 0.1
      }))
    }

    const drawStar = (particle) => {
      if (!ctx.value) return
      
      ctx.value.save()
      ctx.value.translate(particle.x, particle.y)
      ctx.value.rotate(particle.angle)
      ctx.value.fillStyle = 'rgba(246, 249, 250, 0.8)'
      
      const step = Math.PI / particle.points
      ctx.value.beginPath()
      for(let i = 0; i < 2 * particle.points; i++){
        const radius = i % 2 === 0 ? particle.size : particle.size * 0.5
        const x = radius * Math.cos(i * step)
        const y = radius * Math.sin(i * step)
        if(i === 0) ctx.value.moveTo(x, y)
        else ctx.value.lineTo(x, y)
      }
      ctx.value.closePath()
      ctx.value.fill()
      ctx.value.restore()
    }

    const animate = () => {
      if (!ctx.value || !snowCanvas.value) return
      
      ctx.value.clearRect(0, 0, snowCanvas.value.width, snowCanvas.value.height)

      particles.value.forEach(particle => {
        particle.y += particle.dy
        particle.x += particle.dx
        particle.angle += particle.rotation

        if (particle.y > snowCanvas.value.height + 100 || 
            particle.x < -100 || 
            particle.x > snowCanvas.value.width + 100) {
          particle.x = Math.random() * snowCanvas.value.width
          particle.y = Math.random() * -snowCanvas.value.height
        }

        drawStar(particle)
      })

      animationFrameId.value = requestAnimationFrame(animate)
    }

    const handleResize = () => {
      if (!snowCanvas.value) return
      snowCanvas.value.width = window.innerWidth
      snowCanvas.value.height = window.innerHeight
      createParticles()
    }

    onMounted(async () => {
      errorMessage.value = getRandomMessage()
      
      try {
        const Parallax = await import('parallax-js')
        const sceneEl = document.querySelector('.scene')
        if (sceneEl) {
          scene.value = new Parallax.default(sceneEl, {
            relativeInput: true,
            hoverOnly: false
          })
        }
      } catch (error) {
        console.warn('Parallax library not loaded, continuing without parallax effect')
      }
      
      initSnow()
      updateDateTime()
      const intervalId = setInterval(updateDateTime, 1000)
      window.addEventListener('resize', handleResize)
      
      return () => {
        clearInterval(intervalId)
        window.removeEventListener('resize', handleResize)
        cancelAnimationFrame(animationFrameId.value)
        if (scene.value) {
          scene.value.destroy()
        }
      }
    })

    onUnmounted(() => {
      window.removeEventListener('resize', handleResize)
      cancelAnimationFrame(animationFrameId.value)
      if (scene.value) {
        scene.value.destroy()
      }
    })

    return {
      snowCanvas,
      currentDateTime,
      errorMessage
    }
  }
}
</script>

<style scoped>
.not-found {
  height: 100vh;
  overflow: hidden;
  background: linear-gradient(120deg, #ff9a9e, #fad0c4, #fbc2eb, #a18cd1, #fad0c4, #ffd1ff);
  background-size: 400% 400%;
  position: relative;
  animation: gradientFlow 15s ease infinite;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
}

@keyframes gradientFlow {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

.snow {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 1;
}

.main-content {
  position: relative;
  z-index: 2;
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
  box-sizing: border-box;
}

/* 场景包装器 */
.scene-wrapper {
  position: relative;
  width: 100%;
  height: 350px;
  margin-top: auto;
  margin-bottom: 20px;
  overflow: visible;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 场景 */
.scene {
  position: absolute;
  width: 100%;
  height: 100%;
  vertical-align: middle;
  top: 0;
  left: 0;
}

.one,
.two,
.three,
.circle,
.p404 {
  width: 60%;
  height: 60%;
  top: 15% !important;
  left: 20% !important;
  min-width: 400px;
  min-height: 400px;
}

.content {
  width: 600px;
  height: 600px;
  display: flex;
  justify-content: center;
  align-items: center;
  position: absolute;
  top: 45% !important;
  left: 50%;
  transform: translate(-50%, -50%);
  animation: content 0.8s cubic-bezier(1, 0.06, 0.25, 1) backwards;
}

@keyframes content {
  0% {
    width: 0;
  }
}

.piece {
  width: 200px;
  height: 80px;
  display: flex;
  position: absolute;
  border-radius: 80px;
  z-index: 1;
  animation: pieceLeft 8s cubic-bezier(1, 0.06, 0.25, 1) infinite both;
}

@keyframes pieceLeft {
  50% {
    left: 80%;
    width: 10%;
  }
}

@keyframes pieceRight {
  50% {
    right: 80%;
    width: 10%;
  }
}

.p404 {
  font-size: 180px;
  font-weight: 700;
  letter-spacing: 4px;
  color: white;
  display: flex !important;
  justify-content: center;
  position: absolute;
  z-index: 2;
  animation: anime404 0.6s cubic-bezier(0.3, 0.8, 1, 1.05) both;
  animation-delay: 1.2s;
  top: 40% !important;
  transform: translateY(-50%);
  text-shadow: 0 4px 10px rgba(27, 145, 99, 0.92);
}

@keyframes anime404 {
  0% {
    opacity: 0;
    transform: scale(10) skew(20deg, 20deg) translateY(-50%);
  }
}

.p404:nth-of-type(2) {
  color: #109ed6ff;
  z-index: 1;
  animation-delay: 1s;
  filter: blur(10px);
  opacity: 0.8;
  top: 40% !important;
}

.circle:before {
  content: '';
  position: absolute;
  width: 700px;
  height: 700px;
  background-color: rgba(24, 63, 79, 0.03);
  border-radius: 100%;
  top: 45% !important;
  left: 50%;
  transform: translate(-50%, -50%);
  box-shadow: inset 5px 20px 40px rgba(54, 24, 79, 0.25),
              inset 5px 0px 5px rgba(50, 36, 62, 0.3),
              inset 5px 5px 20px rgba(50, 36, 62, 0.25),
              2px 2px 5px rgba(255, 255, 255, 0.2);
  animation: circle 0.8s cubic-bezier(1, 0.06, 0.25, 1) backwards;
}

@keyframes circle {
  0% {
    width: 0;
    height: 0;
  }
}

.one .content:before {
  content: '';
  position: absolute;
  width: 500px;
  height: 500px;
  background-color: rgba(197, 184, 207, 0.12);
  border-radius: 100%;
  box-shadow: inset 5px 20px 40px rgba(54, 24, 79, 0.25),
              inset 5px 0px 5px rgba(50, 36, 62, 0.3),
              inset 5px 5px 20px rgba(50, 36, 62, 0.25),
              2px 2px 5px rgba(255, 255, 255, 0.2);
  animation: circle 0.8s 0.4s cubic-bezier(1, 0.06, 0.25, 1) backwards;
}

.one .piece {
  background: linear-gradient(90deg, #8077EA 13.7%, #EB73FF 94.65%);
}

.one .piece:nth-child(1) {
  right: 15%;
  top: 18%;
  height: 30px;
  width: 120px;
  animation-delay: 0.5s;
  animation-name: pieceRight;
}

.one .piece:nth-child(2) {
  left: 15%;
  top: 45%;
  width: 150px;
  height: 50px;
  animation-delay: 1s;
  animation-name: pieceLeft;
}

.one .piece:nth-child(3) {
  left: 10%;
  top: 75%;
  height: 20px;
  width: 70px;
  animation-delay: 1.5s;
  animation-name: pieceLeft;
}

/* Container 2 */
.two .piece {
  background: linear-gradient(90deg, #FFEDC0 0%, #FF9D87 100%);
}

.two .piece:nth-child(1) {
  left: 0%;
  top: 25%;
  height: 40px;
  width: 120px;
  animation-delay: 2s;
  animation-name: pieceLeft;
}

.two .piece:nth-child(2) {
  right: 15%;
  top: 35%;
  width: 180px;
  height: 50px;
  animation-delay: 2.5s;
  animation-name: pieceRight;
}

.two .piece:nth-child(3) {
  right: 10%;
  top: 80%;
  height: 20px;
  width: 160px;
  animation-delay: 3s;
  animation-name: pieceRight;
}

/* Container 3 */
.three .piece {
  background: #FB8A8A;
}

.three .piece:nth-child(1) {
  left: 25%;
  top: 35%;
  height: 20px;
  width: 80px;
  animation-name: pieceLeft;
  animation-delay: 3.5s;
}

.three .piece:nth-child(2) {
  right: 10%;
  top: 55%;
  width: 140px;
  height: 40px;
  animation-name: pieceRight;
  animation-delay: 4s;
}

.three .piece:nth-child(3) {
  left: 40%;
  top: 68%;
  height: 20px;
  width: 80px;
  animation-name: pieceLeft;
  animation-delay: 4.5s;
}

.message-section {
  text-align: center;
  padding: 20px;
  pointer-events: auto;
  z-index: 3;
  position: relative;
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
  margin-top: auto;
  margin-bottom: 30px;
}

#error-message {
  font-size: 1.4rem;
  margin: 1.5rem 0;
  min-height: 60px;
  font-weight: 600;
  color: white;
  line-height: 1.6;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.6);
  padding: 10px 0;
  animation: fadeInUp 0.8s ease-out 1.5s both;
}

.home-link {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 14px 35px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 50px;
  text-decoration: none;
  font-weight: 600;
  font-size: 1.2rem;
  transition: all 0.3s ease;
  margin-top: 1rem;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
  animation: fadeInUp 0.8s ease-out 2.1s both;
}

.home-link:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.25);
  background: linear-gradient(135deg, #5a6fd8 0%, #6a3f8f 100%);
}

.home-link:active {
  transform: translateY(-1px);
}

.home-icon {
  font-size: 1.3rem;
}

.time-display-bottom {
  font-size: 1.1rem;
  color: #34495e;
  font-weight: 500;
  background: rgba(255, 255, 255, 0.3);
  padding: 12px 24px;
  border-radius: 25px;
  backdrop-filter: blur(15px);
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.15);
  margin-bottom: 20px;
  text-align: center;
  width: auto;
  min-width: 300px;
  animation: fadeInUp 0.8s ease-out 2.4s both;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 响应式设计 */
@media screen and (max-width: 799px) {
  .scene-wrapper {
    height: 250px;
    margin-bottom: 15px;
  }
  
  .one,
  .two,
  .three,
  .circle,
  .p404 {
    width: 90%;
    height: 90%;
    top: 10% !important;
    left: 5% !important;
    min-width: 280px;
    min-height: 280px;
  }
  
  .p404 {
    font-size: 80px;
    top: 35% !important;
  }
  
  .p404:nth-of-type(2) {
    top: 35% !important;
  }
  
  .circle:before {
    width: 300px;
    height: 300px;
    top: 40% !important;
  }
  
  .one .content:before {
    width: 250px;
    height: 250px;
  }
  
  .content {
    width: 250px;
    height: 250px;
    top: 40% !important;
  }
  
  .message-section {
    padding: 15px;
    margin-bottom: 20px;
  }
  
  #error-message {
    font-size: 1.1rem;
    margin: 1rem 0;
  }
  
  .home-link {
    padding: 12px 28px;
    font-size: 1.1rem;
    margin-top: 0.5rem;
  }
  
  .time-display-bottom {
    font-size: 0.95rem;
    padding: 10px 20px;
    min-width: 250px;
    margin-bottom: 10px;
  }
}

@media screen and (min-width: 800px) and (max-width: 1024px) {
  .scene-wrapper {
    height: 300px;
  }
  
  .p404 {
    font-size: 150px;
    top: 38% !important;
  }
  
  .p404:nth-of-type(2) {
    top: 38% !important;
  }
  
  .circle:before {
    width: 500px;
    height: 500px;
    top: 42% !important;
  }
  
  .one .content:before {
    width: 400px;
    height: 400px;
  }
  
  .content {
    width: 400px;
    height: 400px;
    top: 42% !important;
  }
}
</style>