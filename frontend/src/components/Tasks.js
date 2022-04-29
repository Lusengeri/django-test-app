import React from "react";
import Task from "./Task";

const Tasks = ({ tasks, onDelete, onToggle }) => {
    return (
        <>
            {tasks.length <= 0 ? "No Tasks to show": tasks.map(task =>
                 (<Task key={task.id} task={task} onDelete={onDelete} onToggle={onToggle}/>))}
        </>
    )
}

export default Tasks;