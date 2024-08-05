import React from 'react';
import logo from './logo.svg';
import styled, { keyframes } from 'styled-components';
import { createGlobalStyle } from 'styled-components';
import {ClientSideOnlyMap} from './ClientSideOnlyMap.js'
import { MyMap } from './Map.js'
import { createTheme, ThemeProvider } from '@mui/material/styles'

const GlobalStyle = createGlobalStyle`
  body {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }

  code {
    font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
  }
`

// Define your animation
const spin = keyframes`
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
`;

const Div = styled.div`
  text-align: center;
`;
  
const Header = styled.header`
  background-color: #282c34;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
  color: white;
`;

const Logo = styled.img`
  height: 40vmin;
  pointer-events: none;

  /* Apply the animation */
  @media (prefers-reduced-motion: no-preference) {
    animation: ${spin} infinite 20s linear;
  }
`;

const Link = styled.a`
  color: #61dafb;
`;

// function App() {
//   return (
//           <ThemeProvider theme={theme}>
//       <GlobalStyle/>
//       <Div>
//         <Header>
//           <Logo src={logo} alt="logo" />
//           <p>
//             Edit <code>src/App.js</code> and save to reload.
//           </p>
//           <Link
//             href="https://reactjs.org"
//             target="_blank"
//             rel="noopener noreferrer"
//             >
//             Learn React 88
//           </Link>
//         </Header>
//       </Div>
//        </ThemeProvider>
//   );
// }


const theme = createTheme({
  palette: {
    primary: {
      main: '#3f51b5',
    },
    secondary: {
      main: '#f44336',
    },
  },
});

function App () {
  return (
    <>
      <GlobalStyle/>
      <ThemeProvider theme={theme}>
        <Div className="App">
          <p>Bonjour</p>
          <ClientSideOnlyMap  />
        </Div>
      </ThemeProvider>
    </>
  );
}

export default App;
