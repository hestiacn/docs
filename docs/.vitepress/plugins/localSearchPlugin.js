export default function LocalSearchPlugin() {
    return {
      name: 'resolve-local-search-index',
      resolveId(id) {
        if (id === '/@localSearchIndex') {
          return id;
        }
      },
      load(id) {
        if (id === '/@localSearchIndex') {
          return 'export default {};'; 
        }
      }
    }
  }