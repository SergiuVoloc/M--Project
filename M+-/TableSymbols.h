#pragma once
#ifndef MAX_SYMBOL_NAME
#define MAX_SYMBOL_NAME 255
#endif // !MAX_SYMBOL_NAME

#ifndef MAX_DATATYPE_NAME
#define MAX_DATATYPE_NAME 127
#endif // !MAX_DATATYPE_NAME

#define MAX_NODE_TYPE 50
#define MAX_EXTRA_DATA 50

/* If variable is local or global */
enum IdentifierScope {
	Local = 0,
	Global
};

typedef struct symTableEntry {
	/* symbol name */
	char symbolName[MAX_SYMBOL_NAME];
	/* type: int, const, ... */
	char dataType[MAX_DATATYPE_NAME];
	/* if function or variable */
	int symbolType;
	/* local or global */
	enum IdentifierScope symbolScope;
	/* if is define inside another function, should be local function */
	char contextName[MAX_SYMBOL_NAME];
	/* number of children for one SymTableEntry root */
	int numLinks;

}SymTableEntry;

typedef struct node {
	SymTableEntry symTableEntry;
	struct node** links;
}SymNode;