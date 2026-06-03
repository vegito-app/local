package task

import (
	"context"
	"fmt"
	"time"

	"github.com/vegito-app/ai-nestor/nestor/internal/agent"
)

type ID string

type Task struct {
	ID    ID
	Goal  string
	State string

	Result string
	Error  string

	CreatedAt time.Time
	UpdatedAt time.Time
}

func (t *Task) Run(ctx context.Context, toolRegistry agent.ToolRunner) error {
	select {
	case <-ctx.Done():
		return ctx.Err()
	default:
	}

	t.State = "running"

	fmt.Printf("[task:%s] goal=%s\n", t.ID, t.Goal)

	fmt.Printf("[task:%s] starting agent loop\n", t.ID)
	agentRunner := agent.New(toolRegistry)

	result, err := agentRunner.RunGoal(ctx, t.Goal)
	fmt.Printf("[task:%s] agent returned\n", t.ID)
	if err != nil {
		t.Error = err.Error()
		t.UpdatedAt = time.Now()
		t.State = "failed"
		fmt.Printf("[task:%s] failed: %v\n", t.ID, err)
		return err
	}

	fmt.Printf("[task:%s] result=%s\n", t.ID, result)

	t.Result = result
	t.Error = ""
	t.UpdatedAt = time.Now()
	t.State = "done"
	return nil
}
