package task

import (
	"context"
	"fmt"
	"sync"
	"sync/atomic"
	"time"
)

type Loop struct {
	counter          atomic.Uint64
	stop             func()
	tasks            chan Task
	tools            *Tools
	runningTasks     map[string]Task
	runningTasksLock sync.RWMutex
	completedTasks   map[string]Task
}

func NewLoop(ctx context.Context, tools *Tools) *Loop {
	loopExited := make(chan struct{})
	ctx, cancel := context.WithCancel(ctx)
	t := &Loop{
		stop: func() {
			cancel()
			<-loopExited
		},
		tasks:            make(chan Task),
		runningTasks:     make(map[string]Task),
		runningTasksLock: sync.RWMutex{},
		completedTasks:   make(map[string]Task),
		tools:            tools,
	}
	go func() {
		defer close(loopExited)
		t.Run(ctx, tools)
	}()
	return t
}

func (l *Loop) Stop() {
	if l.stop != nil {
		l.stop()
		l.stop = nil
	}
}

func (l *Loop) addRunningTask(id string, task Task) {
	l.runningTasksLock.Lock()
	defer l.runningTasksLock.Unlock()
	l.runningTasks[id] = task
}

func (l *Loop) removeRunningTask(id string) {
	l.runningTasksLock.Lock()
	defer l.runningTasksLock.Unlock()
	delete(l.runningTasks, id)
}

func (l *Loop) addCompletedTask(id string, task Task) {
	l.runningTasksLock.Lock()
	defer l.runningTasksLock.Unlock()
	l.completedTasks[id] = task
}

func (l *Loop) Run(ctx context.Context, tools *Tools) {
	for {
		select {
		case <-ctx.Done():
			return
		case t, ok := <-l.tasks:
			if !ok {
				return
			}
			l.addRunningTask(string(t.ID), t)
			if err := t.Run(ctx, l); err != nil {
				fmt.Printf("[task:%s] error=%v\n", t.ID, err)
			}
			l.removeRunningTask(string(t.ID))
			l.addCompletedTask(string(t.ID), t)
		default:
			time.Sleep(1 * time.Second)
		}
	}
}

func (l *Loop) RunTask(name string, args map[string]string) (string, error) {
	tool, exists := l.tools.Get(name)
	if !exists {
		return "", fmt.Errorf("unknown tool: %s", name)
	}

	return tool.Run(args)
}

func (l *Loop) SubmitTask(goal string) (ID, error) {
	id := ID(fmt.Sprintf("task-%d", l.counter.Load()))
	task := Task{
		ID:        id,
		Goal:      goal,
		State:     "queued",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	l.tasks <- task
	l.counter.Add(1)

	return id, nil
}
func (l *Loop) GetTask(id string) (Task, error) {
	l.runningTasksLock.RLock()
	defer l.runningTasksLock.RUnlock()

	if t, exists := l.runningTasks[id]; exists {
		return t, nil
	}

	if t, exists := l.completedTasks[id]; exists {
		return t, nil
	}

	return Task{}, fmt.Errorf("task not found: %s", id)
}
func (l *Loop) ListTasks() []Task {
	l.runningTasksLock.RLock()
	defer l.runningTasksLock.RUnlock()

	tasks := make([]Task, 0, len(l.runningTasks)+len(l.completedTasks))

	for _, t := range l.runningTasks {
		tasks = append(tasks, t)
	}

	for _, t := range l.completedTasks {
		tasks = append(tasks, t)
	}

	return tasks
}

func (l *Loop) ToolNames() []string {
	// Implementation for returning tool names
	return l.tools.Names()
}

func (l *Loop) GetRunningTasks() []Task {
	l.runningTasksLock.RLock()
	defer l.runningTasksLock.RUnlock()
	tasks := make([]Task, 0, len(l.runningTasks))
	for _, t := range l.runningTasks {
		tasks = append(tasks, t)
	}
	return tasks
}
