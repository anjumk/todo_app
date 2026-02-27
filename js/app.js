// ===== Theme Toggle =====
const themeToggle = document.getElementById('theme-toggle');

function initTheme() {
  const saved = localStorage.getItem('theme');
  if (saved) {
    setTheme(saved);
  } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
    setTheme('dark');
  } else {
    setTheme('light');
  }
}

function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  themeToggle.textContent = theme === 'dark' ? '☀️' : '🌙';
  localStorage.setItem('theme', theme);
}

themeToggle.addEventListener('click', () => {
  const current = document.documentElement.getAttribute('data-theme');
  setTheme(current === 'dark' ? 'light' : 'dark');
});

initTheme();

// ===== Todo Logic =====
const form = document.getElementById('todo-form');
const input = document.getElementById('todo-input');
const todoList = document.getElementById('todo-list');
const taskCount = document.getElementById('task-count');

// Update task counter
function updateTaskCount() {
  const total = todoList.children.length;
  const completed = todoList.querySelectorAll('.completed').length;
  
  if (total === 0) {
    taskCount.textContent = '0 tasks';
  } else if (completed === total) {
    taskCount.textContent = `🎉 All ${total} tasks completed!`;
  } else {
    taskCount.textContent = `${total - completed} of ${total} tasks`;
  }
}

form.addEventListener('submit', (e) => {
  e.preventDefault();
  const text = input.value.trim();
  if (!text) return;
  
  // Add subtle shake if input is empty
  if (!text) {
    input.style.animation = 'shake 0.3s ease';
    setTimeout(() => {
      input.style.animation = '';
    }, 300);
    return;
  }
  
  addTodo(text);
  input.value = '';
  input.focus();
});

function addTodo(text) {
  const li = document.createElement('li');

  const checkbox = document.createElement('input');
  checkbox.type = 'checkbox';
  checkbox.className = 'todo-checkbox';
  checkbox.addEventListener('change', () => {
    li.classList.toggle('completed', checkbox.checked);
    updateTaskCount();
  });

  const span = document.createElement('span');
  span.className = 'todo-text';
  span.textContent = text;

  span.addEventListener('click', () => {
    checkbox.checked = !checkbox.checked;
    li.classList.toggle('completed', checkbox.checked);
    updateTaskCount();
  });

  const deleteBtn = document.createElement('button');
  deleteBtn.className = 'delete-btn';
  deleteBtn.textContent = 'Delete';
  deleteBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    li.classList.add('removing');
    setTimeout(() => {
      li.remove();
      updateTaskCount();
    }, 400);
  });

  li.appendChild(checkbox);
  li.appendChild(span);
  li.appendChild(deleteBtn);
  todoList.appendChild(li);
  
  updateTaskCount();
}

// Add CSS for shake animation
const style = document.createElement('style');
style.textContent = `
  @keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-10px); }
    75% { transform: translateX(10px); }
  }
`;
document.head.appendChild(style);

// Initialize counter
updateTaskCount();
