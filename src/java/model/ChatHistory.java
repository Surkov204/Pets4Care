package model;

public class ChatHistory {
    private String message;
    private boolean user;

    public ChatHistory(String message, boolean user) {
        this.message = message;
        this.user = user;
    }

    public String getMessage() {
        return message;
    }

    public boolean isUser() {
        return user;
    }
}
