import React from "react";
import { useState } from "react";

const AddTask = ({ onSaveTask } ) => {
    const [title, setTitle] = useState('')
    const [completed, setCompleted] = useState(false)

    const onSubmit = (e) => {
        e.preventDefault()

        if (!title) {
            alert('Please type in task details')
            return
        }
        onSaveTask({ title: title, completed: completed })
        setTitle('')
        setCompleted(false)
    }
        return (
            <form className='add-form' onSubmit={onSubmit}>
                <div className='form-control'>
                    <label>Task</label>
                    <input value={title} type='text' placeholder='Add Task' onChange={(e) => setTitle(e.currentTarget.value)}/>
                </div>
                <div className='form-control form-control-check'>
                    <label>Completed</label>
                    <input checked={completed} type='checkbox' onChange={(e) => setCompleted(e.currentTarget.checked)}/>
                </div>           
                <input type='submit' value='Save Task' className='btn btn-block'/>
            </form>
    )
}

export default AddTask;