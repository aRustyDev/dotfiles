---
id: a1b2c3d4-e5f6-7890-abcd-ef1234567890
title: Dotfiles Data Dashboard
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:11
project: dotfiles
scope:
  - meta
  - data
type: dashboard
status: ✅ active
publish: true
tags:
  - dashboard
  - charts
  - dataview
  - meta-analysis
aliases:
  - Data Charts
  - Repository Analytics
related:
  - ref: "[[ollama-embeddings]]"
    description: Embedding model configuration
  - ref: "[[model-dependencies]]"
    description: Model configuration reference
---

# Dotfiles Data Dashboard

Interactive visualizations for meta-analysis of repository data files in `.data/`.

---

## Homebrew Package Categories

Distribution of casks by inferred category (based on naming patterns).

```dataviewjs
const raw = await app.vault.adapter.read(".data/brew.json");
const data = JSON.parse(raw);
const casks = data.casks;

// Categorize casks by common patterns
const categories = {
  'Kubernetes/Container': [],
  'Development Tools': [],
  'Security/Scanning': [],
  'Terminal/TUI': [],
  'Git/VCS': [],
  'Language Runtimes': [],
  'Shell/CLI': [],
  'Network/Monitoring': [],
  'Other': []
};

casks.forEach(c => {
  if (/k9s|kubectl|helm|kubectx|kubetui|kdash|cilium|container|dive|ctop|cruise|lazycontainer/.test(c)) {
    categories['Kubernetes/Container'].push(c);
  } else if (/grype|trivy|falcoctl|gpg|wireshark|termshark|mitmproxy/.test(c)) {
    categories['Security/Scanning'].push(c);
  } else if (/git|lazygit|grv|gittype|delta/.test(c)) {
    categories['Git/VCS'].push(c);
  } else if (/golang|rustup|pyenv|python|cargo|zig|roc|mise/.test(c)) {
    categories['Language Runtimes'].push(c);
  } else if (/zsh|bash|starship|atuin|fzf|yazi|bat|lsd|eza|fd|ripgrep|jq|yq/.test(c)) {
    categories['Shell/CLI'].push(c);
  } else if (/btop|bmon|bandwhich|gping|macmon|oxker|otel/.test(c)) {
    categories['Network/Monitoring'].push(c);
  } else if (/nvim|helix|tenv|cue|opa|steampipe|ansible|just/.test(c)) {
    categories['Development Tools'].push(c);
  } else if (/tui|tftui|jqp|pug|nemu|diskonaut|soft-serve|slides|chafa|mpv|browsh/.test(c)) {
    categories['Terminal/TUI'].push(c);
  } else {
    categories['Other'].push(c);
  }
});

const labels = Object.keys(categories).filter(k => categories[k].length > 0);
const values = labels.map(k => categories[k].length);
const colors = [
  'rgba(54, 162, 235, 0.7)',
  'rgba(255, 99, 132, 0.7)',
  'rgba(255, 206, 86, 0.7)',
  'rgba(75, 192, 192, 0.7)',
  'rgba(153, 102, 255, 0.7)',
  'rgba(255, 159, 64, 0.7)',
  'rgba(199, 199, 199, 0.7)',
  'rgba(83, 102, 255, 0.7)',
  'rgba(140, 140, 140, 0.7)'
];

const chartData = {
  type: 'doughnut',
  data: {
    labels: labels,
    datasets: [{
      data: values,
      backgroundColor: colors.slice(0, labels.length),
      borderWidth: 1
    }]
  },
  options: {
    plugins: {
      title: {
        display: true,
        text: `Homebrew Casks by Category (${casks.length} total)`
      },
      legend: {
        position: 'right'
      }
    }
  }
};

window.renderChart(chartData, this.container);
```

---

## Kubectl Plugin Status Distribution

Shows the status breakdown of kubectl plugins (todo, unsupported, etc.).

```dataviewjs
const raw = await app.vault.adapter.read(".data/kube.json");
const data = JSON.parse(raw);
const plugins = data.kube.plugins;

const statusCounts = {};
plugins.forEach(p => {
  statusCounts[p.status] = (statusCounts[p.status] || 0) + 1;
});

const statusColors = {
  'todo': 'rgba(255, 206, 86, 0.7)',
  'unsupported': 'rgba(255, 99, 132, 0.7)',
  'installed': 'rgba(75, 192, 192, 0.7)',
  'active': 'rgba(54, 162, 235, 0.7)'
};

const labels = Object.keys(statusCounts);
const values = Object.values(statusCounts);
const colors = labels.map(s => statusColors[s] || 'rgba(153, 102, 255, 0.7)');

const chartData = {
  type: 'bar',
  data: {
    labels: labels,
    datasets: [{
      label: 'Plugin Count',
      data: values,
      backgroundColor: colors,
      borderWidth: 1
    }]
  },
  options: {
    plugins: {
      title: {
        display: true,
        text: `Kubectl Plugin Status (${plugins.length} total)`
      }
    },
    scales: {
      y: {
        beginAtZero: true
      }
    }
  }
};

window.renderChart(chartData, this.container);
```

---

## Kubectl Plugin Categories

Distribution of plugins by functional category.

```dataviewjs
const raw = await app.vault.adapter.read(".data/kube.json");
const data = JSON.parse(raw);
const plugins = data.kube.plugins;

const categories = {};
plugins.forEach(p => {
  categories[p.category] = (categories[p.category] || 0) + 1;
});

// Sort by count descending
const sorted = Object.entries(categories).sort((a, b) => b[1] - a[1]);
const labels = sorted.map(e => e[0]);
const values = sorted.map(e => e[1]);

const chartData = {
  type: 'bar',
  data: {
    labels: labels,
    datasets: [{
      label: 'Plugins',
      data: values,
      backgroundColor: 'rgba(54, 162, 235, 0.7)',
      borderColor: 'rgba(54, 162, 235, 1)',
      borderWidth: 1
    }]
  },
  options: {
    indexAxis: 'y',
    plugins: {
      title: {
        display: true,
        text: 'Kubectl Plugins by Category'
      },
      legend: {
        display: false
      }
    },
    scales: {
      x: {
        beginAtZero: true
      }
    }
  }
};

window.renderChart(chartData, this.container);
```

---

## Pre-commit Hook Repos by Tag

Distribution of pre-commit hook repositories by primary tag/language.

```dataviewjs
const raw = await app.vault.adapter.read(".data/git-hooks.json");
const data = JSON.parse(raw);
const repos = data.repos;

const tagCounts = {};
repos.forEach(r => {
  if (r.tags && r.tags.length > 0) {
    r.tags.forEach(t => {
      if (t && t !== 'todo') {
        tagCounts[t] = (tagCounts[t] || 0) + 1;
      }
    });
  }
});

// Sort by count descending, take top 15
const sorted = Object.entries(tagCounts).sort((a, b) => b[1] - a[1]).slice(0, 15);
const labels = sorted.map(e => e[0]);
const values = sorted.map(e => e[1]);

const colors = [
  'rgba(255, 99, 132, 0.7)',
  'rgba(54, 162, 235, 0.7)',
  'rgba(255, 206, 86, 0.7)',
  'rgba(75, 192, 192, 0.7)',
  'rgba(153, 102, 255, 0.7)',
  'rgba(255, 159, 64, 0.7)',
  'rgba(199, 199, 199, 0.7)',
  'rgba(83, 102, 255, 0.7)',
  'rgba(140, 140, 140, 0.7)',
  'rgba(255, 99, 71, 0.7)',
  'rgba(60, 179, 113, 0.7)',
  'rgba(238, 130, 238, 0.7)',
  'rgba(106, 90, 205, 0.7)',
  'rgba(255, 215, 0, 0.7)',
  'rgba(0, 191, 255, 0.7)'
];

const chartData = {
  type: 'pie',
  data: {
    labels: labels,
    datasets: [{
      data: values,
      backgroundColor: colors.slice(0, labels.length),
      borderWidth: 1
    }]
  },
  options: {
    plugins: {
      title: {
        display: true,
        text: `Pre-commit Hook Tags (${repos.length} repos)`
      },
      legend: {
        position: 'right'
      }
    }
  }
};

window.renderChart(chartData, this.container);
```

---

## PATH Priority Distribution

Visualization of PATH entries by priority level.

```dataviewjs
const raw = await app.vault.adapter.read(".data/paths.json");
const data = JSON.parse(raw);
const paths = data.pathsd;

const labels = paths.map(p => p.priority.replace(':', ''));
const values = paths.map(p => parseInt(p.name));

const chartData = {
  type: 'bar',
  data: {
    labels: labels,
    datasets: [{
      label: 'Priority Level',
      data: values,
      backgroundColor: values.map(v => {
        if (v <= 20) return 'rgba(255, 99, 132, 0.7)';  // High priority (low number)
        if (v <= 40) return 'rgba(255, 206, 86, 0.7)';  // Medium priority
        if (v <= 60) return 'rgba(75, 192, 192, 0.7)';  // Lower priority
        return 'rgba(153, 102, 255, 0.7)';              // Lowest priority
      }),
      borderWidth: 1
    }]
  },
  options: {
    indexAxis: 'y',
    plugins: {
      title: {
        display: true,
        text: `PATH Priority Order (${paths.length} entries)`
      },
      legend: {
        display: false
      }
    },
    scales: {
      x: {
        beginAtZero: true,
        title: {
          display: true,
          text: 'Priority (lower = higher priority)'
        }
      }
    }
  }
};

window.renderChart(chartData, this.container);
```

---

## Shell Completion Coverage

Tools with shell completion support.

```dataviewjs
const raw = await app.vault.adapter.read(".data/completions.json");
const data = JSON.parse(raw);
const completions = data.completions;

// Analyze shell support from command patterns
const shellSupport = {
  'bash': 0,
  'zsh': 0,
  'fish': 0,
  'powershell': 0,
  'elvish': 0,
  'nushell': 0
};

completions.forEach(c => {
  const cmd = c.cmd.toLowerCase();
  if (cmd.includes('bash')) shellSupport.bash++;
  if (cmd.includes('zsh')) shellSupport.zsh++;
  if (cmd.includes('fish')) shellSupport.fish++;
  if (cmd.includes('powershell')) shellSupport.powershell++;
  if (cmd.includes('elvish')) shellSupport.elvish++;
  if (cmd.includes('nushell')) shellSupport.nushell++;
});

const labels = Object.keys(shellSupport);
const values = Object.values(shellSupport);
const maxVal = Math.max(...values);

const chartData = {
  type: 'radar',
  data: {
    labels: labels,
    datasets: [{
      label: 'Tools with Support',
      data: values,
      backgroundColor: 'rgba(54, 162, 235, 0.3)',
      borderColor: 'rgba(54, 162, 235, 1)',
      borderWidth: 2,
      pointBackgroundColor: 'rgba(54, 162, 235, 1)'
    }]
  },
  options: {
    plugins: {
      title: {
        display: true,
        text: `Shell Completion Coverage (${completions.length} tools)`
      }
    },
    scales: {
      r: {
        beginAtZero: true,
        max: maxVal + 2
      }
    }
  }
};

window.renderChart(chartData, this.container);
```

---

## 1Password Secrets by Type

Distribution of secrets stored in 1Password by type.

```dataviewjs
const raw = await app.vault.adapter.read(".data/rabbits.json");
const data = JSON.parse(raw);
const secrets = data.onepassword;

const typeCounts = {};
secrets.forEach(s => {
  typeCounts[s.kind] = (typeCounts[s.kind] || 0) + 1;
});

const labels = Object.keys(typeCounts);
const values = Object.values(typeCounts);

const typeColors = {
  'ssh': 'rgba(54, 162, 235, 0.7)',
  'certificate': 'rgba(255, 206, 86, 0.7)',
  'pass': 'rgba(75, 192, 192, 0.7)',
  'api_key': 'rgba(255, 99, 132, 0.7)',
  'token': 'rgba(153, 102, 255, 0.7)'
};

const colors = labels.map(l => typeColors[l] || 'rgba(199, 199, 199, 0.7)');

const chartData = {
  type: 'doughnut',
  data: {
    labels: labels,
    datasets: [{
      data: values,
      backgroundColor: colors,
      borderWidth: 2,
      borderColor: '#fff'
    }]
  },
  options: {
    plugins: {
      title: {
        display: true,
        text: `1Password Secrets (${secrets.length} total)`
      },
      legend: {
        position: 'bottom'
      }
    }
  }
};

window.renderChart(chartData, this.container);
```

---

## Bookmarks by Category

Distribution of bookmarks across categories.

```dataviewjs
// Bookmark category counts (from directory structure)
const categories = {
  'blogs': 0,
  'cons': 0,
  'edu': 0,
  'meetups': 0,
  'projects': 0,
  'research': 0,
  'youtube': 0
};

// Note: This uses hardcoded directory names since we can't list directories in dataviewjs
// Update these counts manually or via script if bookmark counts change

const labels = Object.keys(categories);
const values = [3, 2, 3, 2, 2, 3, 2]; // Approximate counts from directory listing

const colors = [
  'rgba(255, 99, 132, 0.7)',
  'rgba(54, 162, 235, 0.7)',
  'rgba(255, 206, 86, 0.7)',
  'rgba(75, 192, 192, 0.7)',
  'rgba(153, 102, 255, 0.7)',
  'rgba(255, 159, 64, 0.7)',
  'rgba(199, 199, 199, 0.7)'
];

const chartData = {
  type: 'polarArea',
  data: {
    labels: labels,
    datasets: [{
      data: values,
      backgroundColor: colors,
      borderWidth: 1
    }]
  },
  options: {
    plugins: {
      title: {
        display: true,
        text: 'Bookmarks by Category'
      },
      legend: {
        position: 'right'
      }
    }
  }
};

window.renderChart(chartData, this.container);
```

---

## Summary Statistics

```dataviewjs
const brewRaw = await app.vault.adapter.read(".data/brew.json");
const kubeRaw = await app.vault.adapter.read(".data/kube.json");
const hooksRaw = await app.vault.adapter.read(".data/git-hooks.json");
const pathsRaw = await app.vault.adapter.read(".data/paths.json");
const completionsRaw = await app.vault.adapter.read(".data/completions.json");
const secretsRaw = await app.vault.adapter.read(".data/rabbits.json");

const brew = JSON.parse(brewRaw);
const kube = JSON.parse(kubeRaw);
const hooks = JSON.parse(hooksRaw);
const paths = JSON.parse(pathsRaw);
const completions = JSON.parse(completionsRaw);
const secrets = JSON.parse(secretsRaw);

const stats = [
  { metric: "Homebrew Taps", count: brew.taps.length },
  { metric: "Homebrew Casks", count: brew.casks.length },
  { metric: "Kubectl Plugins", count: kube.kube.plugins.length },
  { metric: "Pre-commit Repos", count: hooks.repos.length },
  { metric: "PATH Entries", count: paths.pathsd.length },
  { metric: "Shell Completions", count: completions.completions.length },
  { metric: "1Password Secrets", count: secrets.onepassword.length }
];

dv.table(
  ["Metric", "Count"],
  stats.map(s => [s.metric, s.count])
);
```

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
