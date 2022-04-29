import React from "react"
import { FaTimes } from "react-icons/fa"

const Task = ({ task, onDelete, onToggle }) => {
    return (
        <div className={`task ${!task.completed ? 'pending' : 'completed'}`} onDoubleClick={() => onToggle(task.id)}>
            <h3 className="unselectable"> { task.title } <FaTimes style={ deleteIconStyle } onClick={ ()=> onDelete(task.id) }/></h3>
        </div>
    )
}

const deleteIconStyle = {
    color: 'red',
    cursor: 'pointer'
}

export default Task;