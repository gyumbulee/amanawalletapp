<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Support\AddSupportMessageRequest;
use App\Http\Requests\Support\CreateSupportTicketRequest;
use App\Http\Resources\SupportTicketResource;
use App\Repositories\Interfaces\SupportTicketRepositoryInterface;
use App\Services\SupportTicketService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class SupportTicketController extends Controller
{
    public function __construct(
        protected SupportTicketService $ticketService,
        protected SupportTicketRepositoryInterface $ticketRepository
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $tickets = $this->ticketRepository->paginateForUser(
            $request->user(),
            (int) $request->query('per_page', 20)
        );

        return response()->json([
            'tickets' => SupportTicketResource::collection($tickets->items()),
            'meta' => [
                'current_page' => $tickets->currentPage(),
                'last_page' => $tickets->lastPage(),
                'total' => $tickets->total(),
            ],
        ]);
    }

    public function store(CreateSupportTicketRequest $request): JsonResponse
    {
        try {
            $ticket = $this->ticketService->createTicket(
                $request->user(),
                $request->validated('subject'),
                $request->validated('message'),
                $request->validated('transaction_reference')
            );

            return response()->json([
                'message' => 'Support ticket created.',
                'ticket' => new SupportTicketResource($ticket),
            ], 201);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function show(Request $request, string $uuid): JsonResponse
    {
        $ticket = $this->ticketRepository->findByUuidForUser($uuid, $request->user());

        if (! $ticket) {
            return response()->json(['message' => 'Support ticket not found.'], 404);
        }

        $ticket->load('messages', 'transaction');

        return response()->json([
            'ticket' => new SupportTicketResource($ticket),
        ]);
    }

    public function addMessage(AddSupportMessageRequest $request, string $uuid): JsonResponse
    {
        $ticket = $this->ticketRepository->findByUuidForUser($uuid, $request->user());

        if (! $ticket) {
            return response()->json(['message' => 'Support ticket not found.'], 404);
        }

        $ticket = $this->ticketService->addUserReply($ticket, $request->user(), $request->validated('message'));

        return response()->json([
            'message' => 'Reply sent.',
            'ticket' => new SupportTicketResource($ticket),
        ]);
    }
}
