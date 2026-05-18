#!/bin/bash
dnf update -y
dnf install -y nodejs

mkdir -p /home/ec2-user/app/public

cat > /home/ec2-user/app/public/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>3-Tier AWS Architecture</title>
  <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

    :root {
      --bg:       #0a0e1a;
      --surface:  #111827;
      --border:   #1f2d45;
      --accent:   #00c2ff;
      --accent2:  #7c3aed;
      --text:     #e2e8f0;
      --muted:    #64748b;
      --green:    #10b981;
      --mono:     'Space Mono', monospace;
      --sans:     'DM Sans', sans-serif;
    }

    body {
      background: var(--bg);
      color: var(--text);
      font-family: var(--sans);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 2rem;
      overflow-x: hidden;
    }

    /* grid background */
    body::before {
      content: '';
      position: fixed;
      inset: 0;
      background-image:
        linear-gradient(var(--border) 1px, transparent 1px),
        linear-gradient(90deg, var(--border) 1px, transparent 1px);
      background-size: 40px 40px;
      opacity: 0.4;
      pointer-events: none;
    }

    /* glow blob */
    body::after {
      content: '';
      position: fixed;
      top: -200px;
      left: 50%;
      transform: translateX(-50%);
      width: 600px;
      height: 600px;
      background: radial-gradient(circle, rgba(0,194,255,0.08) 0%, transparent 70%);
      pointer-events: none;
    }

    .wrapper {
      width: 100%;
      max-width: 780px;
      position: relative;
      z-index: 1;
      animation: fadeUp 0.8s ease both;
    }

    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(24px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    /* ── header ── */
    .header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 2.5rem;
      flex-wrap: wrap;
      gap: 1rem;
    }

    .logo {
      font-family: var(--mono);
      font-size: 0.75rem;
      color: var(--accent);
      letter-spacing: 0.15em;
      text-transform: uppercase;
    }

    .status-pill {
      display: flex;
      align-items: center;
      gap: 8px;
      background: rgba(16,185,129,0.1);
      border: 1px solid rgba(16,185,129,0.3);
      border-radius: 999px;
      padding: 6px 14px;
      font-family: var(--mono);
      font-size: 0.7rem;
      color: var(--green);
      letter-spacing: 0.1em;
    }

    .dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: var(--green);
      animation: pulse 2s ease infinite;
    }

    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50%       { opacity: 0.5; transform: scale(0.8); }
    }

    /* ── hero ── */
    .hero {
      margin-bottom: 2.5rem;
    }

    .hero h1 {
      font-family: var(--mono);
      font-size: clamp(1.6rem, 4vw, 2.4rem);
      font-weight: 700;
      line-height: 1.2;
      margin-bottom: 0.75rem;
    }

    .hero h1 span {
      color: var(--accent);
    }

    .hero p {
      color: var(--muted);
      font-size: 0.95rem;
      font-weight: 300;
      max-width: 520px;
      line-height: 1.7;
    }

    /* ── cards grid ── */
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 1rem;
      margin-bottom: 1.5rem;
    }

    .card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.25rem 1.5rem;
      transition: border-color 0.2s, transform 0.2s;
      animation: fadeUp 0.8s ease both;
    }

    .card:hover {
      border-color: var(--accent);
      transform: translateY(-2px);
    }

    .card:nth-child(1) { animation-delay: 0.1s; }
    .card:nth-child(2) { animation-delay: 0.2s; }
    .card:nth-child(3) { animation-delay: 0.3s; }
    .card:nth-child(4) { animation-delay: 0.4s; }

    .card-label {
      font-family: var(--mono);
      font-size: 0.65rem;
      color: var(--muted);
      letter-spacing: 0.12em;
      text-transform: uppercase;
      margin-bottom: 0.5rem;
    }

    .card-value {
      font-size: 1rem;
      font-weight: 500;
      color: var(--text);
    }

    .card-value.accent { color: var(--accent); font-family: var(--mono); font-size: 0.9rem; }

    /* ── arch strip ── */
    .arch {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.25rem 1.5rem;
      margin-bottom: 1.5rem;
      animation: fadeUp 0.8s ease 0.5s both;
    }

    .arch-label {
      font-family: var(--mono);
      font-size: 0.65rem;
      color: var(--muted);
      letter-spacing: 0.12em;
      text-transform: uppercase;
      margin-bottom: 1rem;
    }

    .arch-flow {
      display: flex;
      align-items: center;
      gap: 0;
      flex-wrap: wrap;
      gap: 0.5rem;
    }

    .arch-node {
      background: rgba(0,194,255,0.07);
      border: 1px solid rgba(0,194,255,0.2);
      border-radius: 8px;
      padding: 6px 14px;
      font-family: var(--mono);
      font-size: 0.72rem;
      color: var(--accent);
      white-space: nowrap;
    }

    .arch-arrow {
      color: var(--muted);
      font-size: 1rem;
    }

    /* ── footer ── */
    .footer {
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 0.75rem;
      padding-top: 1.5rem;
      border-top: 1px solid var(--border);
      animation: fadeUp 0.8s ease 0.6s both;
    }

    .footer-left {
      font-family: var(--mono);
      font-size: 0.7rem;
      color: var(--muted);
    }

    .footer-left span { color: var(--accent); }

    .tags {
      display: flex;
      gap: 0.5rem;
      flex-wrap: wrap;
    }

    .tag {
      background: rgba(124,58,237,0.1);
      border: 1px solid rgba(124,58,237,0.25);
      color: #a78bfa;
      font-family: var(--mono);
      font-size: 0.65rem;
      padding: 4px 10px;
      border-radius: 6px;
      letter-spacing: 0.05em;
    }
  </style>
</head>
<body>
  <div class="wrapper">

    <div class="header">
      <div class="logo">// aws 3-tier architecture</div>
      <div class="status-pill">
        <div class="dot"></div>
        all systems operational
      </div>
    </div>

    <div class="hero">
      <h1>Running on <span>EC2</span><br/>Behind an ALB</h1>
      <p>Node.js Express app deployed on a private EC2 instance inside a custom VPC. Traffic routed through an Application Load Balancer in the public subnet.</p>
    </div>

    <div class="grid">
      <div class="card">
        <div class="card-label">Runtime</div>
        <div class="card-value">Node.js / Express</div>
      </div>
      <div class="card">
        <div class="card-label">Instance</div>
        <div class="card-value accent">t3.micro</div>
      </div>
      <div class="card">
        <div class="card-label">Region</div>
        <div class="card-value accent">ca-central-1</div>
      </div>
      <div class="card">
        <div class="card-label">Access</div>
        <div class="card-value">SSM Session Manager</div>
      </div>
    </div>

    <div class="arch">
      <div class="arch-label">Request Flow</div>
      <div class="arch-flow">
        <div class="arch-node">Internet</div>
        <div class="arch-arrow">→</div>
        <div class="arch-node">ALB :80</div>
        <div class="arch-arrow">→</div>
        <div class="arch-node">EC2 :3000</div>
        <div class="arch-arrow">→</div>
        <div class="arch-node">RDS MySQL</div>
      </div>
    </div>

    <div class="footer">
      <div class="footer-left">
        Built by <span>Dhruv Barot</span> &nbsp;·&nbsp; Provisioned with Terraform
      </div>
      <div class="tags">
        <span class="tag">Terraform</span>
        <span class="tag">AWS VPC</span>
        <span class="tag">ALB</span>
        <span class="tag">RDS MySQL</span>
      </div>
    </div>

  </div>
</body>
</html>
HTML

cat > /home/ec2-user/app/app.js <<'APP'
const express = require('express')
const path    = require('path')
const app     = express()

app.use(express.static(path.join(__dirname, 'public')))

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' })
})

app.listen(3000, () => {
  console.log('App running on port 3000')
})
APP

cd /home/ec2-user/app
npm init -y
npm install express
node app.js &