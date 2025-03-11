import React, { useState } from 'react';
import { signUp, signIn, googleSignIn } from './firebase'; // Import functions
import './App.css';

function App() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  return (
    <div className="App">
      <h1>Firebase Authentication Test</h1>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      <div>
        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button style={{ backgroundColor: 'orange', color: 'white', padding: '10px 20px', border: 'none', borderRadius: '5px' }} onClick={() => signUp(email, password, setError)}>Sign Up</button>
        <button style={{ backgroundColor: 'red', color: 'white', padding: '10px 20px', border: 'none', borderRadius: '5px' }} onClick={() => signIn(email, password, setError)}>Sign In</button>
        <button style={{ backgroundColor: 'green', color: 'white', padding: '10px 20px', border: 'none', borderRadius: '5px' }} onClick={() => googleSignIn(setError) }>Sign In with Google</button>
      </div>
    </div>
  );
}

export default App;