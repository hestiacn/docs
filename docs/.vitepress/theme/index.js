import { h } from 'vue';
import DefaultTheme from 'vitepress/theme';
import { useData } from 'vitepress';
import CopyToClipboardInput from './components/CopyToClipboardInput.vue'
import '@fortawesome/fontawesome-free/css/all.min.css';
import './styles/custom.scss';
import './styles/rainbow.css';
import 'floating-vue/dist/style.css';
import 'element-plus/dist/index.css';
import FeaturePage from './components/FeaturePage.vue';
import InstallPage from './components/InstallPage.vue';
import NotFound from './components/404.vue';
import 'element-plus/dist/index.css';
import BackToTop from './components/BackToTop.vue';
import LocalSearchPlugin from '../plugins/localSearchPlugin';

import FloatingVue from 'floating-vue';
import ElementPlus from 'element-plus';
import { library } from '@fortawesome/fontawesome-svg-core';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import {
  faGhost,
  faRocket,
  faCat,
  faCloud,
  faUserAstronaut,
  faHome,
} from '@fortawesome/free-solid-svg-icons';

library.add(faGhost, faRocket, faCat, faCloud, faUserAstronaut, faHome);

export default {
  DefaultTheme,
  Layout: () => {
    const { frontmatter } = useData();
    return h(DefaultTheme.Layout, {
      class: frontmatter.value.layoutClass || ''
    });
  },
  vite: {
    plugins: [LocalSearchPlugin()]
  },
  Layout: () => {
    const { frontmatter } = useData();
    const props = {
      class: frontmatter.value?.layoutClass || ''
    };
    return h(DefaultTheme.Layout, props, {
      "not-found": () => h(NotFound),
      "doc-after": () => h(BackToTop), 
    });
  },
  enhanceApp({ app }) {
    app.use(FloatingVue);
    app.use(ElementPlus);

    app.component('FeaturePage', FeaturePage);
    app.component('InstallPage', InstallPage);
    app.component('CopyToClipboardInput', CopyToClipboardInput);
    app.component('FontAwesomeIcon', FontAwesomeIcon); 
    app.component('BackToTop', BackToTop);
  }
};
