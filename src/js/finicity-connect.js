

export const mountFinicityConnect = (
  url,
  onSuccess,
  onCancel,
  onLoaded,
) => {
  window.finicityConnect.launch(url, {
    selector: '#connect-container',
    overlay: 'rgba(255,255,255, 0)',
    width: '200px',
    success: (event) => {
      onSuccess('a')
    },
    cancel: (event) => {
      onCancel('a')
    },
    error: (error) => {
      console.error('Some runtime error was generated during insideConnect ', error);
    },
    loaded: () => {
      onLoaded('a')
    },
    route: (event) => {
      console.log('This is called as the user navigates through Connect ', event);
    },
    user: (event) => {
      console.log('This is called as the user interacts with Connect ', event);
    }
  });
}

