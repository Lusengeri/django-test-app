import './App.css';
import {BrowserRouter as Router, Route, Routes} from 'react-router-dom';
import { useEffect, useState } from 'react';
import Header from './components/Header';
import AddTask from './components/AddTask';
import Tasks from './components/Tasks';
import Footer from './components/Footer';
import About from './components/About';

function App() {
  const [tasks, setTasks] = useState([])
  const [showAddTask, setShowAddTask] = useState(false)

  useEffect(() => {
    const getTasks = async () => {
      const tasksFromServer = await fetchTasks()
      setTasks(tasksFromServer)
    }

    getTasks()
  }, [])

  const fetchTask = async (id) => {
    const res = await fetch(`http://localhost:8000/api/task-detail/${id}/`, {
      method: "GET"
    })

    const fetchedTask = await res.json() 
    return fetchedTask
  }

  const fetchTasks = async () => {
    const res = await fetch("http://localhost:8000/api/task-list/")
    const data = await res.json()
    return data
  }

  const deleteTask = async (id) => {
    console.log("Deleting")
    await fetch(`http://localhost:8000/api/task-delete/${id}/`, { method: "DELETE"})
  }

  const onDelete = async (id) => {
    await deleteTask(id)
    setTasks(tasks.filter(task => task.id !== id))
  }

  const toggleCompletion= async (id) => {
    const currentTask = await fetchTask(id)
    const updatedTask = {...currentTask, completed: !(currentTask.completed)}
    const res = await fetch(`http://localhost:5000/api/task-update/${id}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(updatedTask)
    })

    const newValue = await res.json()

    setTasks(tasks.map(task => task.id === id ? newValue : task))
  }

  const addTask = async (task) => {
    const res = await fetch("http://localhost:8000/api/task-create/", { 
      method: "POST",
      headers: { 
        "Content-Type": "application/json"},
      body: JSON.stringify(task)})

    const newTask = await res.json()

    setTasks([...tasks, newTask])
  }


  return (
    <Router>
      <div className="container">
        <Header title="Task Tracker" onAdd={() => setShowAddTask(!showAddTask)} showAddTask={showAddTask}/>
        {showAddTask && <AddTask onSaveTask={addTask}/>}
        <Routes>
          <Route exact path='/' element={ 
            <div>
              <Tasks tasks={tasks} onDelete={onDelete} onToggle={toggleCompletion}/>
              <Footer />
            </div>
            }/>
          <Route exact path='/about' element={<About/>}/>
        </Routes>
      </div>
    </Router>
  );
}

export default App;